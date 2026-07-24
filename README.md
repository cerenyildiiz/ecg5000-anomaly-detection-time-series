


# Time Series Anomaly Detection with LSTM Autoencoder (ECG5000)

The `ECG5000 ` dataset contains 5,000 ECG heartbeat samples. Each sample consists of 140 numerical features representing the ECG signal and 1 target variable (`class`). There are no missing values in the dataset. More details about the dataset can be found on the OpenML website ([Luís Ferreira, 2022](https://www.openml.org/search?type=data&id=44794)).

## Dataset Structure

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
For the anomaly detection task:
• Normal: Class 1
• Anomalous: Classes 2, 3, 4, and 5
```
>  ##   **References:**
> 1.  **https://www.timeseriesclassification.com/description.php?Dataset=ECG5000** 
> 2. **https://www.openml.org/search?type=data&sort=runs&id=44794&status=active** 
