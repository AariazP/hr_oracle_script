--Se requiere generar un reporte de referencia cruzada (pivot) que
--muestre la cantidad de empleados por nombre de departamento, segmentando esta información en rangos salariales. Los rangos salariales serán definidos como "Inicial",
--"Intermedio", y "Avanzado". Para el propósito de este ejercicio, consideraremos los siguientes criterios para los rangos:
--Inicial: Salarios < $2000.
--• Intermedio: Salarios desde 52000 hasta $5000.
--Avanzado: Salarios > $5000.
--Adicionalmente, es fundamental asegurar que el reporte maneje adecuadamente los valores nulos, tanto para los salarios como para los nombres de los departamentos
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM (
  SELECT COALESCE(d.DEPARTMENT_NAME,'Departamento sin nombre') AS department_name, e.SALARY,
    CASE
      WHEN SALARY < 2000 THEN 'Inicial'
      WHEN SALARY >= 2000 AND SALARY <= 5000 THEN 'Intermedio'
      WHEN SALARY > 5000 THEN 'Avanzado'
      ELSE 'Nulo'
    END AS rango_salarial
  FROM ARIAS.EMPLOYEES e
  JOIN ARIAS.DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
)
PIVOT (
  COUNT(SALARY) AS cantidad_empleados
  FOR rango_salarial IN ('Inicial' AS inicial, 'Intermedio' AS intermedio, 'Avanzado' AS avanzado, 'Nulo' AS nulo)
)
ORDER BY DEPARTMENT_NAME;


------------------------------------------------------------------------------------------------------------------------------------------
--Cada manager_id es el jefe de uno o más empleados, cada uno de los cuales tiene un job_id y gana un salario.
--Para cada jefe, ¿cuál es el salario total que han ganado todos los empleados de cada job_id?
--Escriba una consulta para mostrar los valores Manager_id, job_ id y el salario total.
--Incluya en el resultado el subtotal del salario para cada jefe y una suma total de todos los salarios

SELECT
  e2.MANAGER_ID,
  e.JOB_ID,
  SUM(e.SALARY) AS salario_total
FROM ARIAS.EMPLOYEES e
JOIN ARIAS.EMPLOYEES e2 ON e.MANAGER_ID = e2.EMPLOYEE_ID
GROUP BY ROLLUP(e2.MANAGER_ID, e.JOB_ID)
ORDER BY e2.MANAGER_ID, e.JOB_ID;

------------------------------------------------------------------------------------------------------------------------------------------
--Corrija la consulta anterior para incluir también un subtotal del salario para cada job_id independientemente del manager _id.

SELECT
  e2.MANAGER_ID,
  e.JOB_ID,
  SUM(e.SALARY) AS salario_total
FROM ARIAS.EMPLOYEES e
JOIN ARIAS.EMPLOYEES e2 ON e.MANAGER_ID = e2.EMPLOYEE_ID
GROUP BY CUBE(e2.MANAGER_ID, e.JOB_ID)
ORDER BY e2.MANAGER_ID, e.JOB_ID;


-----------------------------------------------------------------------------------------------------------------------------------------

-- Crear un reporte que muestre el nombre del departamento, el trabajo, el salario promedio por trabajo dentro de cada departamento
-- y el salario promedio de toda la empresa. Para cada trabajo, si el salario promedio es mayor que
-- el salario promedio general, indicar 'Above Average', si es igual
-- 'At Average', de lo contrario 'Below Average'. Además, se requiere el total del salario promedio por departamento
-- y un gran total de todos los salarios. Los departamentos sin empleados deben ser incluidos en el reporte con la nota 'No
-- Employees' y un salario promedio de 0.


SELECT
    NVL(d.department_name, 'No Employees') AS department_name,
    e.job_id,
    AVG(e.salary) AS avg_salary,
    CASE
        WHEN AVG(e.salary) > (SELECT AVG(salary) FROM ARIAS.employees) THEN 'Above Average'
        WHEN AVG(e.salary) = (SELECT AVG(salary) FROM ARIAS.employees) THEN 'At Average'
        ELSE 'Below Average'
    END AS salary_comparison
FROM
    ARIAS.employees e
LEFT JOIN
    ARIAS.departments d ON e.department_id = d.department_id
GROUP BY
    ROLLUP (d.department_name, e.job_id)
ORDER BY
    NVL(d.department_name, 'No Employees'), e.job_id;

--Se solicita desarrollar una consulta que analice y reporte la distribución de salarios y comisiones entre los
-- empleados, teniendo en cuenta su departamento, ubicación, y la relación con sus jefes directos.
-- La consulta debe calcular el total de salarios y comisiones (ajustando comisiones nulas a cero), contar el número de
-- empleados por cada departamento y ubicación, y clasificar los departamentos en rangos de salario promedio ('Bajo' < 5000,
--'Medio' 5000 y 10000, 'Alto' > 10000). Este análisis debe proporcionar una visión comprensiva de cómo la compensación
-- se estructura a través de diferentes niveles y áreas de la organización (departamentos).


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
  d.DEPARTMENT_ID,
  d.DEPARTMENT_NAME,
  l.CITY AS UBICACION,
  COUNT(e.EMPLOYEE_ID) AS NUMERO_EMPLEADOS,
  SUM(NVL(e.SALARY, 0) + NVL(e.COMMISSION_PCT, 0)) AS TOTAL_COMPENSACION,
  CASE
    WHEN AVG(NVL(e.SALARY, 0) + NVL(e.COMMISSION_PCT, 0)) < 5000 THEN 'Bajo'
    WHEN AVG(NVL(e.SALARY, 0) + NVL(e.COMMISSION_PCT, 0)) BETWEEN 5000 AND 10000 THEN 'Medio'
    ELSE 'Alto'
  END AS RANGO_SALARIO_PROMEDIO
FROM ARIAS.DEPARTMENTS d
JOIN ARIAS.LOCATIONS l ON d.LOCATION_ID = l.LOCATION_ID
LEFT JOIN ARIAS.EMPLOYEES e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
GROUP BY d.DEPARTMENT_ID, d.DEPARTMENT_NAME, l.CITY
ORDER BY d.DEPARTMENT_ID, l.CITY;



--Cree una consulta que permita agregar un bono al salario dependiendo de si tienen una comisión o no.
-- Si tienen comisión, agregar un bono del 10% del salario. Si no, agregar un bono del
SELECT  LAST_NAME, SALARY + NVL2(COMMISSION_PCT, SALARY*0.1, SALARY*0.05) SALARIO_MAS_BONO FROM EMPLOYEES;


