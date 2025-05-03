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