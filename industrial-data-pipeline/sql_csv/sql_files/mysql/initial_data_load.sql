use industrial_data;

SHOW TABLES

CREATE TABLE Machines (
    MachineID INT PRIMARY KEY,
    MachineName VARCHAR(50) NOT NULL
);

CREATE TABLE MachineStatus (
    StatusID INT PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL
);

CREATE TABLE AlarmCodes (
    AlarmID INT PRIMARY KEY,
    AlarmDescription VARCHAR(100) NOT NULL
);


CREATE TABLE Operators (
    OperatorID INT PRIMARY KEY
);

-- once created the above table will be populated with data from the csv file located in industrial-data-pipeline/sql_csv/metadata

DROP TABLE staging_iot;

CREATE TABLE staging_iot (
  Timestamp VARCHAR(50),
  Temperature_C DOUBLE,
  Vibration_mm_s DOUBLE,
  Pressure_bar DOUBLE,
  Machine_ID VARCHAR(50)
);

DROP TABLE staging_mes;

CREATE TABLE staging_mes (
  Timestamp VARCHAR(50),
  Operator_ID VARCHAR(50),
  Units_Produced INT,
  Defective_Units INT,
  Production_Time_min INT,
  Machine_ID VARCHAR(50)
);

DROP TABLE staging_scada;

CREATE TABLE staging_scada (
  Timestamp VARCHAR(50),
  Power_Consumption_kW DOUBLE,
  Machine_ID VARCHAR(50),
  Alarm_Code VARCHAR(50),
  Machine_Status VARCHAR(50)
);

-- once created the above table will be populated with data from the csv file located in industrial-data-pipeline/sql_csv/one-time_load/
-- post this load from csv files for historical data, the tables will be populated with resolved foreign keys from metadata tables

DROP TABLE IOT;

CREATE TABLE IOT (
  Timestamp VARCHAR(50),
  Temperature_C DOUBLE,
  Vibration_mm_s DOUBLE,
  Pressure_bar DOUBLE,
  MachineID INT,
  FOREIGN KEY (MachineID) REFERENCES Machines(MachineID)
);


INSERT INTO IOT (Timestamp, Temperature_C, Vibration_mm_s, Pressure_bar, MachineID)
SELECT 
  s.Timestamp,
  s.Temperature_C,
  s.Vibration_mm_s,
  s.Pressure_bar,
  m.MachineID
FROM staging_iot s
JOIN Machines m ON s.Machine_ID = m.MachineName;

SELECT count(*) from IOT;

DROP TABLE synthetic_mes_data;

CREATE TABLE synthetic_mes_data (
  Timestamp VARCHAR(50),
  Operator_ID INT,
  Units_Produced INT,
  Defective_Units INT,
  Production_Time_min INT,
  MachineID INT,
  FOREIGN KEY (Operator_ID) REFERENCES Operators(OperatorID),
  FOREIGN KEY (MachineID) REFERENCES Machines(MachineID)
);


INSERT INTO synthetic_mes_data (
  Timestamp, Operator_ID, Units_Produced, Defective_Units, Production_Time_min, MachineID
)
SELECT 
  s.Timestamp,
  o.OperatorID,
  s.Units_Produced,
  s.Defective_Units,
  s.Production_Time_min,
  m.MachineID
FROM staging_mes s
JOIN Operators o ON s.Operator_ID  = o.OperatorID
JOIN Machines m ON s.Machine_ID  = m.MachineName;

select count(*) from synthetic_mes_data

DROP TABLE synthetic_scada_data

CREATE TABLE synthetic_scada_data (
  Timestamp VARCHAR(50),
  Power_Consumption_kW DOUBLE,
  MachineID INT,
  ALARM_CODE_ID INT,
  Machine_Status_ID INT,
  FOREIGN KEY (MachineID) REFERENCES Machines(MachineID),
  FOREIGN KEY (ALARM_CODE_ID) REFERENCES AlarmCodes(AlarmID),
  FOREIGN KEY (Machine_Status_ID) REFERENCES MachineStatus(StatusID)
);

INSERT INTO synthetic_scada_data (
  Timestamp, Power_Consumption_kW, MachineID, ALARM_CODE_ID, Machine_Status_ID
)
SELECT 

  s.Timestamp,
  s.Power_Consumption_kW,
  m.MachineID,
  a.AlarmID ,
  ms.StatusID
FROM staging_scada s
JOIN Machines m ON s.Machine_ID = m.MachineName
JOIN AlarmCodes a ON s.Alarm_Code = a.AlarmDescription
JOIN MachineStatus ms ON s.Machine_Status = ms.StatusName;

select count(*) from synthetic_scada_data ssd ;