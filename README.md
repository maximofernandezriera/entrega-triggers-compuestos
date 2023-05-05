# Triggers compuestos en plpgsql

En PostgreSQL, un trigger de tipo compuesto es un tipo especial de trigger que se define en una tabla y dispara la ejecución de una función compuesta que se compone de varias subfunciones. La función compuesta se ejecutará cuando se cumpla una condición específica en la tabla, como una actualización, inserción o eliminación de registros. 

Aquí hay un ejemplo paso a paso de cómo crear un trigger compuesto en PostgreSQL:

1. Primero, debemos crear una función compuesta que se ejecutará cuando se active el trigger. Supongamos que queremos crear una función compuesta que actualice dos campos en la tabla "employees" cuando se inserte un nuevo registro. Para ello, creamos una función compuesta como esta:

```
CREATE FUNCTION update_employee_info()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE employees
  SET salary = NEW.salary * 1.05,
      job_title = 'Manager'
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Esta función compuesta actualiza el salario y el título del trabajo del empleado recién insertado multiplicando el salario por 1.05 y estableciendo el título del trabajo en "Manager".

2. A continuación, podemos crear el trigger compuesto en la tabla "employees". Para ello, utilizamos la siguiente sintaxis:

```
CREATE TRIGGER update_employee_trigger
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION update_employee_info();
```

Este trigger compuesto se activará después de cada inserción en la tabla "employees" y ejecutará la función compuesta "update_employee_info".

3. Ahora, cuando se inserte un nuevo registro en la tabla "employees", el trigger compuesto se activará y ejecutará la función compuesta "update_employee_info". Por ejemplo, si insertamos un nuevo registro con el siguiente comando:

```
INSERT INTO employees (id, name, salary) VALUES (1, 'Juan Pérez', 50000);
```

El trigger compuesto se activará y ejecutará la función compuesta "update_employee_info", lo que actualizará el salario y el título del trabajo del empleado recién insertado. Podemos verificar que los campos se hayan actualizado con el siguiente comando:

```
SELECT * FROM employees WHERE id = 1;
```
