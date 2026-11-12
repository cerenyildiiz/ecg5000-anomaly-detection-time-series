


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
│   ├── ecg-description.json
│   └── README.md                  # Dataset documentation
│
├── my paper/
│   └── README.md                  # Project manuscript and LaTeX files
│
├── papers/                        # Related research papers
│
├── plots/                         # Generated figures
│
├── ecg.R                          # R implementation
├── ecg5000.py                     # Python implementation
├── my-study.tex                   # LaTeX manuscript
└── README.md                      # Project overview
```

## Dataset Structure

This folder contains the ECG5000 dataset used in this study.

```text
data/
├── ECG5000.zip
├── ECG5000_TRAIN.txt
├── ECG5000_TEST.txt
├── ecg.csv
├── ecg-description.json
└── README.md
```

| File | Description |
|------|-------------|
| `ECG5000.zip` | Original ECG5000 dataset archive downloaded from the source. |
| `ECG5000_TRAIN.txt` | Original training dataset. |
| `ECG5000_TEST.txt` | Original test dataset. |
| `ecg.csv` | Combined dataset created by merging the training and test sets. |
| `ecg-description.json` | Dataset metadata, including dataset characteristics and descriptive information. |
| `README.md` | Documentation for the dataset folder. |


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


## Project Timeline

Undoubtedly, creating a Gantt chart is a great way to establish a more structured and well-organized workflow. Below is an example of a chart illustrating the project planning and timeline.(Gantt Chart Using the Base R `plot()` Function)


<img width="2000" height="1300" alt="image" src="https://github.com/user-attachments/assets/03f585a0-008c-4c07-b991-d10b816f64dc" />


*Fig. 5. Gantt chart of the project phases (July – November 2026).*

[ Gantt Charts – Community Contributions for EDAV](https://jtr13.github.io/cc19/gantt-charts.html)
## Research Paper

### Literature Investigation with a Preliminary ECG5000 Case Study

The full manuscript is available below:

[Anomaly Detection for Healthcare Applications (PDF)](my%20paper/Anomaly%20Detection%20for%20Healthcare%20Applications.pdf)

This paper reviews deep learning approaches for detecting abnormal patterns in biomedical time-series data, using ECG signals as an example. It also presents a preliminary 1D-CNN experiment on the ECG5000 dataset. LSTM-based anomaly detection and SHAP explainability are discussed as potential extensions; they are not evaluated in this version of the study.


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
<div align="center">

| Setting | Value |
|---------|-------|
| Model | Single-Layer 1D CNN |
| Optimizer | Adam |
| Learning Rate | 0.001 |
| Loss Function | Mean Squared Error (MSE) |
| Batch Size | 32 |
| Epochs | 10 |

</div>



<img width="1309" height="1600" alt="image" src="https://github.com/user-attachments/assets/951f9186-307b-4c73-adcd-a50d259d459c" />



*Figure 4. Architecture of the proposed 1D CNN model for ECG classification.*

In the literature, several studies have adopted SMOTE to mitigate class imbalance and have employed Logistic Regression (LR) and Support Vector Machine (SVM)-based approaches.Also,Explainable Artificial Intelligence (XAI) techniques, particularly SHAP, have been used to enhance the interpretability of model predictions (Nayana & Vinay, 2026).




 
## Explainable Artificial Intelligence (XAI)

Since the data are time-series data, the SHAP analysis will be performed over the time dimension.





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
