
# install.packages(c("torch", "readr", "dplyr", "ggplot2", "tidyr", "coro"))

library(torch) # used for PyTorch-based tensors and deep learning in R
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)
library(coro)

set.seed(123)
torch_manual_seed(123)

device <- if (cuda_is_available()) torch_device("cuda") else torch_device("cpu")
device


# Import dataset
train_path <- "C:/Users/pc/Downloads/ECG5000_TRAIN.txt"
test_path  <- "C:/Users/pc/Downloads/ECG5000_TEST.txt"

train <- read_table(train_path, col_names = FALSE, show_col_types = FALSE)
test  <- read_table(test_path,  col_names = FALSE, show_col_types = FALSE)

ecg <- rbind(train, test)

colnames(ecg) <- c("target", paste0("time_", 1:140))

# Combine and shuffle, as in the original workflow.
set.seed(123)
ecg <- ecg[sample(nrow(ecg)), ]
rownames(ecg) <- NULL

dim(ecg)
table(ecg$target)


# Exploratory Data Analysis of Heartbeat Classes

class_names <- c(
  `1` = "Normal",
  `2` = "R on T",
  `3` = "PVC",
  `4` = "SP",
  `5` = "UB"
)

class_distribution <- ecg %>%
  count(target) %>%
  mutate(class_name = unname(class_names[as.character(target)]))

ggplot(class_distribution, aes(x = class_name, y = n)) +
  geom_col(fill = "#4F5679", width = 0.75) +
  labs(x = "Heartbeat Class", y = "Frequency") +
  theme_minimal()


# Normal and anomalous data split

CLASS_NORMAL <- 1

normal_data <- ecg %>%
  filter(target == CLASS_NORMAL) %>%
  select(-target)

anomaly_data <- ecg %>%
  filter(target != CLASS_NORMAL) %>%
  select(-target)

dim(normal_data)
dim(anomaly_data)

# Use only normal heartbeats for train and validation
set.seed(123)
n_normal <- nrow(normal_data)

train_indices <- sample(
  seq_len(n_normal),
  size = floor(0.85 * n_normal)
)

train_normal <- normal_data[train_indices, ]
remaining_normal <- normal_data[-train_indices, ]

val_indices <- sample(
  seq_len(nrow(remaining_normal)),
  size = floor(0.67 * nrow(remaining_normal))
)

val_normal <- remaining_normal[val_indices, ]
test_normal <- remaining_normal[-val_indices, ]

dim(train_normal)
dim(val_normal)
dim(test_normal)


#  Convert the Data into Tensors and Create DataLoaders

create_tensor <- function(data) {
  torch_tensor(as.matrix(data), dtype = torch_float())$unsqueeze(3)
}

train_tensor <- create_tensor(train_normal)
val_tensor <- create_tensor(val_normal)
test_normal_tensor <- create_tensor(test_normal)
test_anomaly_tensor <- create_tensor(anomaly_data)

ecg_dataset <- dataset(
  name = "ECGDataset",

  initialize = function(x) {
    self$x <- x
  },

  .getitem = function(index) {
    self$x[index, , ]
  },

  .length = function() {
    self$x$size(1)
  }
)

batch_size <- 16

train_loader <- dataloader(
  ecg_dataset(train_tensor),
  batch_size = batch_size,
  shuffle = TRUE
)

val_loader <- dataloader(
  ecg_dataset(val_tensor),
  batch_size = batch_size,
  shuffle = FALSE
)

# Remove raw data objects after tensor creation to reduce memory usage
rm(
  train, test, ecg, normal_data, anomaly_data,
  train_normal, remaining_normal, val_normal, test_normal
)
gc()


# LSTM AUTOENCODER

encoder_module <- nn_module(
  initialize = function(n_features = 1, embedding_dim = 128) {
    self$embedding_dim <- embedding_dim
    self$hidden_dim <- 2 * embedding_dim

    self$lstm1 <- nn_lstm(
      input_size = n_features,
      hidden_size = self$hidden_dim,
      batch_first = TRUE
    )

    self$lstm2 <- nn_lstm(
      input_size = self$hidden_dim,
      hidden_size = embedding_dim,
      batch_first = TRUE
    )
  },

  forward = function(x) {
    output1 <- self$lstm1(x)
    x <- output1[[1]]

    output2 <- self$lstm2(x)
    hidden_state <- output2[[2]][[1]]

    hidden_state[-1, , ]
  }
)

decoder_module <- nn_module(
  initialize = function(seq_len = 140, embedding_dim = 128, n_features = 1) {
    self$seq_len <- seq_len
    self$embedding_dim <- embedding_dim
    self$hidden_dim <- 2 * embedding_dim

    self$lstm1 <- nn_lstm(
      input_size = embedding_dim,
      hidden_size = embedding_dim,
      batch_first = TRUE
    )

    self$lstm2 <- nn_lstm(
      input_size = embedding_dim,
      hidden_size = self$hidden_dim,
      batch_first = TRUE
    )

    self$output_layer <- nn_linear(
      in_features = self$hidden_dim,
      out_features = n_features
    )
  },

  forward = function(x) {
    x <- x$unsqueeze(2)
    x <- x$`repeat`(c(1, self$seq_len, 1))

    output1 <- self$lstm1(x)
    x <- output1[[1]]

    output2 <- self$lstm2(x)
    x <- output2[[1]]

    self$output_layer(x)
  }
)

lstm_autoencoder <- nn_module(
  initialize = function(seq_len = 140, n_features = 1, embedding_dim = 128) {
    self$encoder <- encoder_module(
      n_features = n_features,
      embedding_dim = embedding_dim
    )

    self$decoder <- decoder_module(
      seq_len = seq_len,
      embedding_dim = embedding_dim,
      n_features = n_features
    )
  },

  forward = function(x) {
    encoded <- self$encoder(x)
    self$decoder(encoded)
  }
)

model <- lstm_autoencoder(
  seq_len = 140,
  n_features = 1,
  embedding_dim = 128
)$to(device = device)

model


# Training steps
optimizer <- optim_adam(model$parameters, lr = 0.001)
num_epochs <- 75
patience <- 10
min_delta <- 0.01
epochs_without_improvement <- 0

history <- data.frame(
  epoch = seq_len(num_epochs),
  train_loss = NA_real_,
  val_loss = NA_real_
)

best_val_loss <- Inf
best_model_path <- "best_lstm_autoencoder.pt"

for (epoch in seq_len(num_epochs)) {
  model$train()
  train_loss_sum <- 0
  train_batch_count <- 0

  coro::loop(for (batch in train_loader) {
    batch <- batch$to(device = device)
    optimizer$zero_grad()

    reconstruction <- model(batch)
    loss <- nnf_l1_loss(reconstruction, batch, reduction = "sum") / batch$size(1)

    loss$backward()
    optimizer$step()

    train_loss_sum <- train_loss_sum + loss$item()
    train_batch_count <- train_batch_count + 1
  })

  model$eval()
  val_loss_sum <- 0
  val_batch_count <- 0

  with_no_grad({
    coro::loop(for (batch in val_loader) {
      batch <- batch$to(device = device)
      reconstruction <- model(batch)
      loss <- nnf_l1_loss(reconstruction, batch, reduction = "sum") / batch$size(1)

      val_loss_sum <- val_loss_sum + loss$item()
      val_batch_count <- val_batch_count + 1
    })
  })

  mean_train_loss <- train_loss_sum / train_batch_count
  mean_val_loss <- val_loss_sum / val_batch_count

  history$train_loss[epoch] <- mean_train_loss
  history$val_loss[epoch] <- mean_val_loss

  if (mean_val_loss < best_val_loss - min_delta) {
    best_val_loss <- mean_val_loss
    epochs_without_improvement <- 0
    torch_save(model$state_dict(), best_model_path)
  } else {
    epochs_without_improvement <- epochs_without_improvement + 1
  }

  message(
    "Epoch ", epoch, "/", num_epochs,
    " | train loss: ", round(mean_train_loss, 4),
    " | val loss: ", round(mean_val_loss, 4)
  )

  gc()

  if (epochs_without_improvement >= patience) {
    message(
      "Early stopping at epoch ", epoch,
      " | best validation loss: ", round(best_val_loss, 4)
    )
    break
  }
}

# Remove empty rows if training stops before epoch 75
history <- history %>%
  filter(!is.na(train_loss), !is.na(val_loss))

write_csv(history, "training_history.csv")

# Load the epoch with the smallest validation loss.
model$load_state_dict(torch_load(best_model_path, device = device))
model$eval()


# Training history
history_long <- history %>%
  pivot_longer(
    cols = c(train_loss, val_loss),
    names_to = "dataset",
    values_to = "loss"
  ) %>%
  mutate(
    dataset = factor(
      dataset,
      levels = c("train_loss", "val_loss"),
      labels = c("Training Loss", "Validation Loss")
    )
  )

ggplot(history_long, aes(x = epoch, y = loss, color = dataset)) +
  geom_line(linewidth = 1.1, lineend = "round") +
  scale_color_manual(
    values = c(
      "Training Loss" = "#243B67",
      "Validation Loss" = "#D76A5B"
    )
  ) +
  scale_x_continuous(
    breaks = pretty(history$epoch, n = 10),
    expand = expansion(mult = c(0.01, 0.02))
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0.03, 0.08))
  ) +
  labs(
    title = "Model Learning Curve",
    subtitle = "Training and validation reconstruction loss across epochs",
    x = "Epoch",
    y = "L1 Reconstruction Loss",
    color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 15, color = "#20242B"),
    plot.subtitle = element_text(
      size = 10.5,
      color = "#69717D",
      margin = margin(b = 12)
    ),
    axis.title = element_text(face = "bold", color = "#343A40"),
    axis.text = element_text(color = "#555D68"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E7E9ED", linewidth = 0.35),
    plot.margin = margin(15, 18, 12, 15)
  )


#  Reconstruction loss and threshold calculation 

calculate_losses <- function(model, tensor, device, batch_size = 16) {
  loader <- dataloader(
    ecg_dataset(tensor),
    batch_size = batch_size,
    shuffle = FALSE
  )

  model$eval()
  all_losses <- numeric(0)

  with_no_grad({
    coro::loop(for (batch in loader) {
      batch <- batch$to(device = device)
      reconstruction <- model(batch)

      batch_losses <- torch_abs(reconstruction - batch)$sum(dim = c(2, 3))
      all_losses <- c(all_losses, as.numeric(as_array(batch_losses$to(device = "cpu"))))
    })
  })

  all_losses
}

train_losses <- calculate_losses(model, train_tensor, device, batch_size)

# Data-dependent threshold 
threshold <- as.numeric(quantile(train_losses, probs = 0.95))
threshold

loss_data <- data.frame(reconstruction_loss = train_losses)

ggplot(loss_data, aes(x = reconstruction_loss)) +
  geom_histogram(bins = 50, fill = "#4F5679", color = "white") +
  geom_vline(
    xintercept = threshold,
    linetype = "dashed",
    linewidth = 0.8,
    color = "firebrick4"
  ) +
  labs(x = "Reconstruction Loss", y = "Frequency") +
  theme_minimal()


# Evaluate the model performance 
normal_losses <- calculate_losses(model, test_normal_tensor, device, batch_size)
anomaly_losses <- calculate_losses(model, test_anomaly_tensor, device, batch_size)

normal_prediction <- ifelse(normal_losses > threshold, "Anomaly", "Normal")
anomaly_prediction <- ifelse(anomaly_losses > threshold, "Anomaly", "Normal")

actual <- factor(
  c(
    rep("Normal", length(normal_prediction)),
    rep("Anomaly", length(anomaly_prediction))
  ),
  levels = c("Normal", "Anomaly")
)

predicted <- factor(
  c(normal_prediction, anomaly_prediction),
  levels = c("Normal", "Anomaly")
)

confusion_matrix <- table(Actual = actual, Predicted = predicted)
confusion_matrix

TN <- confusion_matrix["Normal", "Normal"]
FP <- confusion_matrix["Normal", "Anomaly"]
FN <- confusion_matrix["Anomaly", "Normal"]
TP <- confusion_matrix["Anomaly", "Anomaly"]

accuracy <- (TP + TN) / sum(confusion_matrix)
error_rate <- 1 - accuracy
sensitivity <- TP / (TP + FN)
specificity <- TN / (TN + FP)
precision <- TP / (TP + FP)
f1_score <- 2 * precision * sensitivity / (precision + sensitivity)

metrics <- data.frame(
  Accuracy = accuracy,
  Error_Rate = error_rate,
  Sensitivity = sensitivity,
  Specificity = specificity,
  Precision = precision,
  F1_Score = f1_score
)

metrics
write_csv(metrics, "model_metrics.csv")


# Compare original and reconstructed ECG signals
plot_reconstruction <- function(model, tensor, index, device, signal_type) {
  x <- tensor[index, , , drop = FALSE]$to(device = device)

  with_no_grad({
    reconstruction <- model(x)
  })

  original <- as.numeric(as_array(x$to(device = "cpu")$squeeze()))
  reconstructed <- as.numeric(
    as_array(reconstruction$to(device = "cpu")$squeeze())
  )

  example_loss <- sum(abs(original - reconstructed))

  plot_frame <- data.frame(
    time = seq_along(original),
    Original = original,
    Reconstruction = reconstructed
  ) %>%
    pivot_longer(
      cols = c(Original, Reconstruction),
      names_to = "Signal",
      values_to = "Value"
    )

  ggplot(plot_frame, aes(x = time, y = Value, color = Signal)) +
    geom_line(linewidth = 0.8) +
    scale_color_manual(
      values = c(Original = "#202020", Reconstruction = "firebrick4")
    ) +
    labs(
      title = paste0(signal_type, " ECG | L1 loss = ", round(example_loss, 2)),
      subtitle = paste0("Threshold = ", round(threshold, 2)),
      x = "Time Point",
      y = "ECG Value",
      color = NULL
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
}

# Normal example
plot_reconstruction(
  model,
  test_normal_tensor,
  index = 1,
  device = device,
  signal_type = "Normal"
)

# Anomaly example
plot_reconstruction(
  model,
  test_anomaly_tensor,
  index = 1,
  device = device,
  signal_type = "Anomaly"
)
