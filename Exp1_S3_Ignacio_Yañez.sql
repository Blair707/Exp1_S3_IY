SET VERIFY OFF

-- CASO 1: Análisis de Propiedades

SELECT p.id_tipo_propiedad                                          "TIPO",
       COUNT(*)                                                     "TOTAL_PROPIEDADES",
       TO_CHAR(MAX(p.valor_arriendo), '$999G999G999')               "MAX_ARRIENDO",
       TO_CHAR(ROUND(AVG(p.valor_arriendo)), '$999G999G999')        "PROMEDIO_ARRIENDO",
       TO_CHAR(MIN(p.valor_arriendo), '$999G999G999')               "MIN_ARRIENDO",
       CASE
            WHEN MAX(p.valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
            ELSE 'PREMIUM'
       END                                                          "CLASIFICACION",
       TO_CHAR(SUM(NVL(p.valor_gasto_comun, 0)), '$999G999G999')    "TOTAL_GASTOS_COMUNES"
FROM   propiedad p
GROUP BY p.id_tipo_propiedad
HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(p.valor_gasto_comun, 0)) DESC;

-- CASO 2: Análisis de antiguedad de empleados

SELECT UPPER(e.nombre_emp || ' ' || e.appaterno_emp)                "Nombre Empleado",
       TO_CHAR(e.sueldo_emp, '$9G999G999')                          "Sueldo con Formato",
       CASE
            WHEN e.sueldo_emp > 2000000 THEN 'ALTO'
            ELSE 'MEDIO'
       END                                                          "Clasificación Sueldo",
       TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)            "Años Antigüedad",
       CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) <= 10 THEN
                 'Corresponde bono ' || LPAD('5', 2)  || '%: ' ||
                 TO_CHAR(ROUND(e.sueldo_emp * 0.05), '$999G999G999')
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) <= 20 THEN
                 'Corresponde bono ' || LPAD('10', 2) || '%: ' ||
                 TO_CHAR(ROUND(e.sueldo_emp * 0.10), '$999G999G999')
            ELSE
                 'Corresponde bono ' || LPAD('15', 2) || '%: ' ||
                 TO_CHAR(ROUND(e.sueldo_emp * 0.15), '$999G999G999')
       END                                                          "BONO"
FROM   empleado e
WHERE  e.id_categoria_emp = 3
AND    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 5
AND    e.id_sucursal <> &CODIGO_SUCURSAL
ORDER BY e.sueldo_emp DESC;

-- CASO 3: Lista de clientes

SELECT CASE
            WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
            WHEN c.renta_cli >= 600000  THEN 'ALTA'
            WHEN c.renta_cli >= 300000  THEN 'MEDIA'
            ELSE 'BAJA'
       END                                                          "CLASIFICACION_RENTA",
       COUNT(*)                                                     "CANTIDAD_CLIENTES",
       TO_CHAR(ROUND(AVG(c.renta_cli)), '$999G999G999')             "RENTA_PROMEDIO",
       CASE
            WHEN COUNT(NVL(c.fonofijo_cli, c.celular_cli)) = 0
                 THEN 'Clientes Sin Teléfono'
            ELSE 'Clientes con Teléfono'
       END                                                          "ESTADO_TELEFONO"
FROM   cliente c
GROUP BY CASE
              WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
              WHEN c.renta_cli >= 600000  THEN 'ALTA'
              WHEN c.renta_cli >= 300000  THEN 'MEDIA'
              ELSE 'BAJA'
         END
HAVING AVG(c.renta_cli) > 200000;
