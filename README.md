


# Time Series Anomaly Detection with LSTM Autoencoder (ECG5000)

The `ECG5000 ` dataset contains 5,000 ECG heartbeat samples. Each sample consists of 140 numerical features representing the ECG signal and 1 target variable (`class`). There are no missing values in the dataset. More details about the dataset can be found on the OpenML website ([Luís Ferreira, 2022](https://www.openml.org/search?type=data&id=44794)).


## Project Structure

```text
ecg5000-anomaly-detection-time-series/
│
├── data/
│   ├── ECG5000.zip
│   ├── ECG5000_TRAIN.txt
│   ├── ECG5000_TEST.txt
│   ├── ecg.csv
│   └── README.md
│
├── my paper/
│   └── README.md #Project manuscript and LaTeX files
│
├── papers/
│   └── Related research papers...
│
├── ecg5000.py
├── my-study.tex
└── README.md
```
## Dataset File Structure

This folder contains the ECG5000 dataset used in this study.

```text
data/
├── ECG5000.zip
├── ECG5000_TRAIN.txt
├── ECG5000_TEST.txt
├── ecg.csv
└── README.md
```

| File | Description |
|------|-------------|
| `ECG5000.zip` | Original ECG5000 dataset archive downloaded from the source. |
| `ECG5000_TRAIN.txt` | Original training dataset. |
| `ECG5000_TEST.txt` | Original test dataset. |
| `ecg.csv` | Combined CSV file created by merging the original training and test datasets for this project. |
| `README.md` | Description of the dataset files included in this folder. |



## Purpose of the Study


The aim of this study is to use electrocardiogram (ECG) data to detect anomalies in a patient’s heartbeat.
```text
The ECG5000 dataset includes five different heartbeat classes. Since this study focuses on anomaly detection, these classes are grouped into normal and anomalous heartbeats as follows:

1. Normal beat (N)
2. R-on-T Premature Ventricular Contraction (R-on-T PVC)
3. Premature Ventricular Contraction (PVC)
4. Supraventricular Premature or Ectopic Beat (SP)
5. Unclassified Beat (UB)
```


```text
For the anomaly detection task:
• Normal: Class 1
• Anomalous: Classes 2, 3, 4, and 5
```




## Exploratory Data Analysis 


<img width="3000" height="1800" alt="heartbeat_class_distribution" src="https://github.com/user-attachments/assets/703da7ac-0c55-4864-94e8-c3af6eb71e8d" />





*Fig. 1. The graph shows the distribution of heartbeat classes(target) in the ECG5000 dataset.*


<img width="9900" height="6300" alt="image" src="https://github.com/user-attachments/assets/49fade5f-9f5e-4eaf-972d-fcea4411117f" />

*Fig. 2. The graph shows the mean ECG signals of the five heartbeat classes.*



Amplitude represents the electrical potential of the heart measured at each time point. Each heartbeat in the ECG5000 dataset is represented as a sequence of 140 amplitude values over time.

This study is presented in two parts.In the first part, 






##  1D Convolutional Neural Network (1D CNN)

```text

A single-layer 1D CNN is used for processing one-dimensional data such as time series and signal data. Therefore, this study begins with the introduction of the 1D CNN architecture. 

```
<img width="7000" height="4200" alt="cnn_learning_curve" src="https://github.com/user-attachments/assets/13b4550c-466e-406a-9306-32d5b4774963" />



*Fig. 3. The graph shows the training and validation MSE loss of the 1D CNN model over 10 epochs.*



##  Hyperparameters
| Setting | Value |
|----------|-------|
| Model | Single-Layer 1D CNN |
| Optimizer | Adam |
| Learning Rate | 0.001 |
| Loss Function | Mean Squared Error (MSE) |
| Batch Size | 32 |
| Epochs | 10 |




<img width="1309" height="1600" alt="image" src="https://github.com/user-attachments/assets/951f9186-307b-4c73-adcd-a50d259d459c" />



## Languages
```text
- Python
- R (for detailed Explainable AI (XAI) analysis and visualizations)
```


## References

- **Time Series Classification Archive ECG5000 Dataset (Chen & Keogh, n.d.)**
  https://www.timeseriesclassification.com/description.php?Dataset=ECG5000

- **OpenML – ECG5000 Dataset (Luís Ferreira, 2022)**  
  https://www.openml.org/search?type=data&sort=runs&id=44794&status=active
