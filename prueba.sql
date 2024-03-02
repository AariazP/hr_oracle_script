SELECT * FROM JOBS;
SELECT * FROM EMPLOYEES;
SELECT * FROM DEPARTMENTS;
SELECT * FROM REGIONS;
SELECT * FROM LOCATIONS;
SELECT * FROM JOB_HISTORY;
SELECT EXTRACT(YEAR FROM HIRE_DATE) year FROM EMPLOYEES;

--Pivot para encontrar el salario por años de los empleados que se encuentran entre los departamentos 50 y 100

SELECT * FROM (
    SELECT EXTRACT(YEAR FROM HIRE_DATE) year, EMPLOYEE_ID, SALARY
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID>=50 AND DEPARTMENT_ID<101
)
PIVOT (
    SUM(SALARY) FOR year IN (2013,2014,2015,2016,2017, 2018)
);

-- Encontrar la suma de salarios por departamento y luego encontrar el total de salario entre los
-- departamentos con id menor a 50
SELECT department_id, job_id, SUM(salary)
FROM employees
WHERE department_id < 50
GROUP BY ROLLUP (department_id, job_id);

--Encontrar todas las combinaciones en las distintas dimesiones de la tabla

SELECT department_id, job_id, SUM(salary)
FROM employees
WHERE department_id < 50
GROUP BY CUBE (department_id, job_id);

--Permite agrupar segun las combinaciones que se desean
-- agrupar == solo mostrar unos campos

SELECT department_id, job_id, SUM(salary)
FROM employees
WHERE department_id < 50
GROUP BY GROUPING SETS ( (department_id, job_id));

-- Encontrar la suma de salarios por departamento y luego encontrar el total de salario entre los
-- departamentos con id menor a 50

SELECT grouping(department_id),
       grouping(job_id),
       SUM(salary)
FROM employees
WHERE department_id < 50
GROUP BY ROLLUP (department_id, job_id);



CREATE OR REPLACE VIEW EmpDepVentas AS SELECT last_name || ' ' || first_name name FROM EMPLOYEES WHERE DEPARTMENT_ID = 100;

SELECT * FROM EmpDepVentas;

--ACTIVIDAD (Pivot - Rollup - Cube - Funciones Null)

--Generar el reporte que permita visualizar el salario mínimo, máximo y
--promedio por departamento.

SELECT * FROM(

    SELECT department_id, salary FROM employees

)PIVOT(

    MIN(salary) AS "Min", MAX(salary) AS "Max", AVG(salary) AS "Avg"
    FOR department_id IN (10 AS "Dep_10", 20 AS "Dep_20", 30 AS "Dep_30")

);

--Generar el reporte que permita visualizar el número de empleados por puesto
--y año de contratación.

SELECT * FROM (

    SELECT JOB_ID, EXTRACT(YEAR FROM e.HIRE_DATE) AS "Anio de contra", e.JOB_ID year FROM EMPLOYEES e

)PIVOT (

    COUNT( JOB_ID ) FOR year IN ('AD_PRES','AD_VP','IT_PROG','FI_MGR','FI_ACCOUNT','PU_MAN','PU_CLERK','ST_MAN','ST_CLERK','SA_REP','SH_CLERK','AD_ASST','MK_MAN','MK_REP','HR_REP','PR_REP','AC_MGR','AC_ACCOUNT')

);


--Generar el reporte que permita visualizar el número de empleados por región
--y departamento.

SELECT * FROM (

    SELECT d.DEPARTMENT_NAME, EMPLOYEE_ID, r.REGION_NAME FROM EMPLOYEES e
                                           JOIN DEPARTMENTS d ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
                                           JOIN LOCATIONS l ON d.LOCATION_ID= l.LOCATION_ID
                                           JOIN COUNTRIES c ON l.COUNTRY_ID = c.COUNTRY_ID
                                           JOIN REGIONS r ON c.REGION_ID = r.REGION_ID

) PIVOT (

    COUNT(employee_id) FOR REGION_NAME IN ('Europe', 'Americas', 'Asia', 'Oceania', 'Africa')

);

-- Generar el reporte que permita visualizar la suma de salarios por ciudad.

SELECT * FROM(

    SELECT e.SALARY, l.city FROM EMPLOYEES e
                            JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
                            JOIN LOCATIONS l ON d.LOCATION_ID = l.LOCATION_ID

) PIVOT (

    SUM(SALARY) FOR CITY IN ('Roma', 'Venice', 'Tokyo', 'Hiroshima','Southlake', 'South San Francisco', 'South Brunswick', 'Seattle','Toronto','Whitehorse','Beijing','Bombay','Sydney','Singapore', 'London','Oxford','Stretford','Munich','Sao Paulo','Geneva','Bern','Utrecht','Mexico City')

);

--Generar el reporte que permita visualizar el número de empleados por puesto
-- en determinados departamentos.

SELECT * FROM(

    SELECT e.employee_id, e.JOB_ID, d.DEPARTMENT_NAME FROM EMPLOYEES e
                         JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID

)PIVOT (

    COUNT(EMPLOYEE_ID) FOR JOB_ID IN ('AD_PRES','AD_VP','IT_PROG','FI_MGR','FI_ACCOUNT','PU_MAN','PU_CLERK','ST_MAN','ST_CLERK','SA_REP','SH_CLERK','AD_ASST','MK_MAN','MK_REP','HR_REP','PR_REP','AC_MGR','AC_ACCOUNT')

);

SELECT * FROM EMPLOYEES WHERE JOB_ID='AD_VP';

-- Generar el reporte que permita visualizar el número de empleados y salario
-- promedio por departamento y trabajo.

SELECT department_id, job_id, COUNT(*) AS employee_count, AVG(salary) AS avg_salary
FROM EMPLOYEES
GROUP BY ROLLUP (department_id, job_id);

-- Generar el reporte que permita visualizar el número de empleados y salario
-- promedio por departamento, trabajo y género (cree el campo género y
-- asígnele de forma aleatoria el valor F o M).

SELECT COUNT(e.employee_id) AS Total_empleados, AVG(e.salary) AS Salario, e.department_id AS Department, e.job_id AS Trabajo
            FROM EMPLOYEES e
            GROUP BY GROUPING SETS ( (employee_id, salary), (JOB_ID, department_id) );

--Generar el reporte que permita visualizar el número de empleados por región,
-- país y ciudad.

SELECT
    L.COUNTRY_ID AS País,
    L.STATE_PROVINCE AS Región,
    L.CITY AS Ciudad,
    COUNT(E.EMPLOYEE_ID) AS Num_Empleados
FROM
    EMPLOYEES E
JOIN
    DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN
    LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
GROUP BY
    ROLLUP (L.COUNTRY_ID, L.STATE_PROVINCE, L.CITY)
ORDER BY
    L.COUNTRY_ID, L.STATE_PROVINCE, L.CITY;

--Generar el reporte que permita visualizar el número de empleados por país y
--ciudad.

SELECT c.country_name, l.city, COUNT(e.employee_id) FROM EMPLOYEES e
        JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
        JOIN LOCATIONS l ON d.LOCATION_ID = l.LOCATION_ID
        JOIN COUNTRIES c ON l.COUNTRY_ID = c.COUNTRY_ID
    GROUP BY ROLLUP (COUNTRY_NAME, CITY)
    ORDER BY COUNTRY_NAME, CITY;

--Generar el reporte que permita visualizar el salario total y promedio por
-- departamento, trabajo y año de contratación.

SELECT e.JOB_ID, EXTRACT(YEAR FROM e.hire_date) as year,  DEPARTMENT_NAME, SUM(SALARY) SALARIO_TOTAL, AVG(SALARY) SALARIO_PROMEDIO FROM EMPLOYEES e
        JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
        GROUP BY ROLLUP (JOB_ID, HIRE_DATE, DEPARTMENT_NAME)
        ORDER BY JOB_ID, HIRE_DATE, DEPARTMENT_NAME;

--Convertir comisiones nulas a 0 y sumarlas al salario.
SELECT employee_id, last_name, NVL(commission_pct, 0) AS commission, salary +
NVL(commission_pct * salary, 0) AS total_salary
FROM employees;

--Mostrar empleados y sus managers, indicando &quot;Sin Manager&quot; si no tienen
--uno.
SELECT e1.EMPLOYEE_ID ID_EMPLEADO, e1.FIRST_NAME AS EMPLEADO,e1.MANAGER_ID,
            NVL2(e1.MANAGER_ID, e2.FIRST_NAME, 'SIN MANAGER') AS MANAGER
            FROM EMPLOYEES e1
            JOIN EMPLOYEES e2 ON e2.MANAGER_ID = e1.EMPLOYEE_ID
            ORDER BY e2.FIRST_NAME DESC;


--Mostrar el nombre del departamento o &quot;Desconocido&quot; si es nulo.

SELECT NVL(DEPARTMENT_NAME, 'DESCONOCIDO') DEPARTMENT_NAME FROM DEPARTMENTS;

--Determinar el salario total incluyendo comisión si está presente, de lo
--contrario, mostrar solo el salario.

SELECT LAST_NAME, SALARY + NVL2(commission_pct, salary * commission_pct, 0) AS SALARIO_PLUS_COMISION FROM EMPLOYEES;

--Agregar un bono al salario dependiendo de si tienen una comisión o no. Si
--tienen comisión, agregar un bono del 10% del salario. Si no, agregar un bono
--del 5%.

SELECT  LAST_NAME, SALARY + NVL2(COMMISSION_PCT, SALARY*0.1, SALARY*0.05) SALARIO_MAS_BONO FROM EMPLOYEES;

--Mostrar el manager de cada empleado, y si no tienen manager mostrar el
-- empleado como su propio manager.

SELECT e1.EMPLOYEE_ID, NVL(e1.MANAGER_ID, e1.EMPLOYEE_ID) MANAGER FROM EMPLOYEES e1
            JOIN EMPLOYEES e2 ON e2.MANAGER_ID = e1.EMPLOYEE_ID GROUP BY e1.EMPLOYEE_ID, e1.MANAGER_ID;

--Mostrar de los empleados que tienen historia de trabajo si han cambiado o no
--de departamento, en caso de que el departamento siga siendo el mismo
--mostrar null, en caso contrario el departamento anterior.

SELECT e.employee_id, e.first_name, NULLIF(jh.department_id, e.department_id)
depto_anterior FROM employees e join job_history jh on jh.employee_id = e.employee_id;

--Mostrar el código, nombre de los empleados y el nombre del jefe del
--departamento en el que trabajan, en caso que sean ellos mismo mostrar null.

SELECT e1.EMPLOYEE_ID, e1.FIRST_NAME, NULLIF(e2.EMPLOYEE_ID, e1.MANAGER_ID)  FROM EMPLOYEES e1
        JOIN EMPLOYEES e2 ON e2.MANAGER_ID = e1.EMPLOYEE_ID;

--Listar el código, nombre de los empleados y su información de contacto (el
--email, en caso de no tener email su número telefónico, si no tiene ninguno de
--los anteriores el nombre de la ciudad en la cual trabajan.

SELECT e.EMPLOYEE_ID, e.FIRST_NAME, COALESCE(e.EMAIL, e.PHONE_NUMBER, l.CITY) INFORMACION FROM EMPLOYEES e
            JOIN DEPARTMENTS d ON e.DEPARTMENT_ID =d.DEPARTMENT_ID
            JOIN LOCATIONS l ON d.LOCATION_ID = l.LOCATION_ID;

--Listar el código,nombre y rango salarial de los empleados, el rango salarial
--está dado por:
--Bajo salario < 5000
--Medio Salario >=5000 y <= 10000
--Alto Salario >10000


SELECT EMPLOYEE_ID, FIRST_NAME, CASE
                                    WHEN SALARY<5000 THEN 'Bajo salario'
                                    WHEN SALARY>=5000 AND SALARY<=10000 THEN 'Medio salario'
                                    ELSE 'Alto salario'
                                END AS RANGO_SALARIAL FROM EMPLOYEES;

-- se desea realizar un incremento salarial a los empleados, este incremento se
-- realizará de la siguiente manera: 10% empleados con un salario menor a 8000
-- y que no tengan comisión; 8% aquellos con un salario menor a 8000 con
-- comisión; 6% a todos los empleados con un salario mayor o igual a 8000.
-- realice el update en una sola sentencia para cumplir este requisito.

SELECT EMPLOYEE_ID, FIRST_NAME, CASE
                                    WHEN SALARY<8000 AND COMMISSION_PCT IS NULL THEN SALARY + SALARY*0.1
                                    WHEN SALARY<5000 AND COMMISSION_PCT IS NOT NULL THEN SALARY + SALARY*0.08
                                    WHEN SALARY>=8000 THEN SALARY + SALARY*0.06
                                END AS NUEVO_SALARIO FROM EMPLOYEES;

-- Listar por región la cantidad de empleados contratados en cada semestre.
-- (Use to_char para obtener el mes o el trimestre y según este valor acumular 1
-- en una columna de primer semestre o en otra columna de segundo trimestre

SELECT * FROM (

    SELECT r.REGION_NAME, e.EMPLOYEE_ID, EXTRACT(MONTH FROM HIRE_DATE) month FROM EMPLOYEES e
                        JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
                        JOIN LOCATIONS l ON d.LOCATION_ID = l.LOCATION_ID
                        JOIN COUNTRIES c ON l.COUNTRY_ID = c.COUNTRY_ID
                        JOIN REGIONS r ON c.REGION_ID = r.REGION_ID
                        JOIN JOB_HISTORY jh ON e.EMPLOYEE_ID = jh.EMPLOYEE_ID

)PIVOT(

    COUNT(EMPLOYEE_ID) FOR REGION_NAME IN ('Europe', 'Americas', 'Asia', 'Oceania', 'Africa')

);