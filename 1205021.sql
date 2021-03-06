--offline 1

Set serveroutput on


DECLARE

MX NUMBER := -1;
MXYEAR NUMBER;

TYPE MONTHNAME IS VARRAY(12) OF VARCHAR2(3);
TYPE MONTHNUM IS VARRAY(12) OF NUMBER;

MN MONTHNAME;
MC MONTHNUM;

CURSOR C1 IS SELECT JOINYEAR, COUNT(*) CNT FROM (SELECT EXTRACT(YEAR FROM HIRE_DATE) AS JOINYEAR FROM EMPLOYEES) GROUP BY JOINYEAR;

CURSOR C2 IS SELECT YY, MM, COUNT(*) AS CNT FROM (SELECT EXTRACT(YEAR FROM HIRE_DATE) AS YY, EXTRACT(MONTH FROM HIRE_DATE) AS MM FROM EMPLOYEES)
GROUP BY (YY,MM)
ORDER BY YY,MM ASC;

EMPYEAR C1%ROWTYPE;
MONTHCNT C2%ROWTYPE;



BEGIN

IF NOT(C1%ISOPEN) THEN OPEN C1;
END IF;

LOOP
  EXIT WHEN (C1%NOTFOUND);
  
  FETCH C1 INTO EMPYEAR;
  
  IF(EMPYEAR.CNT > MX) THEN
    MX := EMPYEAR.CNT;
    MXYEAR := EMPYEAR.JOINYEAR; 
  END IF;

END LOOP;

CLOSE C1;

Dbms_Output.Put('MAXIMUM EMPLOYEES JOINED: ' || MX);
Dbms_Output.Put_Line('   IN THE YEAR: ' || MXYEAR);  


 
MN := MONTHNAME('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC');
MC := MONTHNUM(0,0,0,0,0,0,0,0,0,0,0,0);

IF NOT (C2%ISOPEN) THEN OPEN C2;
END IF;

LOOP
  EXIT WHEN(C2%NOTFOUND);
  
  FETCH C2 INTO MONTHCNT;
  IF(MONTHCNT.YY = MXYEAR) THEN
    --Dbms_Output.Put_Line(MONTHCNT.MM || ' : ' || MONTHCNT.CNT);
    MC(MONTHCNT.MM) := MONTHCNT.CNT;
  END IF;
END LOOP;

CLOSE C2;

FOR II IN 1..12
LOOP
  Dbms_Output.Put_Line(MN(II) || ' : ' || MC(II));
END LOOP;

END;
/




--offline 2

set serveroutput on

CREATE OR REPLACE PROCEDURE DISP_DEPT(C_ID IN VARCHAR2 )
AS 
CURSOR C1 IS 
SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME FROM DEPARTMENTS D JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID WHERE L.COUNTRY_ID = C_ID;

VDEPT C1%ROWTYPE;

BEGIN
/*
SELECT * FROM LOCATIONS;
SELECT * FROM DEPARTMENTS;*/

IF NOT(C1%ISOPEN) THEN OPEN C1;
END IF;

IF(C1%NOTFOUND) THEN DBMS_OUTPUT.PUT_LINE('NO DEPARTMENTS IN THAT COUNTRY!');
ELSE DBMS_OUTPUT.PUT_LINE('THE FOLLOWING DEPARTMETNS ARE IN COUNTRY_ID: ' || C_ID);
END IF;


LOOP
EXIT WHEN C1%NOTFOUND;
FETCH C1 INTO VDEPT;

 DBMS_OUTPUT.PUT_LINE('ID : ' || VDEPT.DEPARTMENT_ID || ' ' || 'DEPARTMENT NAME: ' || VDEPT.DEPARTMENT_NAME);

END LOOP;

CLOSE C1;

END;
/




--offline 3

set serveroutput on

CREATE OR REPLACE TRIGGER LIMIT_JOBS
BEFORE INSERT OR UPDATE 
ON EMPLOYEES
FOR EACH ROW

DECLARE

N NUMBER := 30;

CURSOR C1 IS SELECT JOB_ID, COUNT(*)  AS CNT FROM EMPLOYEES GROUP BY JOB_ID;

VJOBCNT C1%ROWTYPE;

BEGIN

IF NOT (C1%ISOPEN) THEN OPEN C1; END IF;


LOOP
  EXIT WHEN C1%NOTFOUND;
  FETCH C1 INTO VJOBCNT;
  IF(VJOBCNT.CNT > N) THEN
    RAISE_APPLICATION_ERROR(-20001, 'CANNOT BE MORE THAN ' || N || ' EMPLOYEES UNDER A JOB');
  END IF;
  

END LOOP;

CLOSE C1;

END LIMIT_JOBS;
/


/*
insert into employees(employee_id,hire_date,job_id,last_name,email) values (365, '21-AUG-1995', 'SA_REP', 'BOSS', 'abc@gmail.com');

exec disp_dept('US');
*/
