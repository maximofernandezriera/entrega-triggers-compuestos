# Emntrega triggers compuestos en plpgsql

### Un trigger de tipo compuesto es un tipo especial de trigger que se define en una tabla y dispara la ejecución de una función compuesta que se compone de varias subfunciones. La función compuesta se ejecutará cuando se cumpla una condición específica en la tabla, como una actualización, inserción o eliminación de registros.

![Compuesto](https://user-images.githubusercontent.com/43608040/236450402-441c88b5-b773-4fec-9778-d278e8f18eed.png)

## Un primer ejemplo

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

#### Tenéis el script de la bd necesario en este mismo repositorio.

# Un ejemplo más avanzado

Supongamos que tienes una aplicación que permite a los usuarios votar por sus películas favoritas, y quieres asegurarte de que un usuario solo pueda votar por una película una vez. Para ello, puedes crear un trigger compuesto que verifique si el usuario ya ha votado por esa película antes de permitir que el voto se registre en la base de datos.

Aquí está el código paso a paso para crear este trigger compuesto:

1. Primero, debes crear una tabla para almacenar las votaciones de los usuarios. Supongamos que tienes una tabla llamada "movie_votes" que tiene las siguientes columnas: "user_id", "movie_id" y "vote_date".

```
CREATE TABLE movie_votes (
  user_id INTEGER,
  movie_id INTEGER,
  vote_date TIMESTAMP DEFAULT NOW()
);
```

2. A continuación, debes crear una función que se ejecutará cada vez que se inserte una nueva votación en la tabla "movie_votes". Esta función verificará si el usuario ya ha votado por la película, y si es así, cancelará la inserción del nuevo voto.

```
CREATE FUNCTION prevent_duplicate_votes()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM movie_votes
    WHERE user_id = NEW.user_id
      AND movie_id = NEW.movie_id
  ) THEN
    RAISE EXCEPTION 'Duplicate vote not allowed';
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

Esta función compuesta comprueba si ya existe un registro en la tabla "movie_votes" con el mismo "user_id" y "movie_id" que el nuevo registro que se está insertando. Si existe, genera una excepción que indica que el voto duplicado no está permitido. Si no existe, devuelve el nuevo registro.

3. Ahora, puedes crear el trigger compuesto en la tabla "movie_votes" para que se active cada vez que se inserte un nuevo registro. Este trigger compuesto ejecutará la función "prevent_duplicate_votes" que acabamos de crear.

```
CREATE TRIGGER prevent_duplicate_votes_trigger
BEFORE INSERT ON movie_votes
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_votes();
```

Este trigger compuesto se activará antes de cada inserción en la tabla "movie_votes" y ejecutará la función "prevent_duplicate_votes" que acabamos de crear. Si se detecta un voto duplicado, se generará una excepción y la inserción se cancelará.

4. Ahora, si intentamos insertar un voto duplicado en la tabla "movie_votes", se generará una excepción que indicará que el voto duplicado no está permitido. Por ejemplo, si intentamos insertar el siguiente registro:

```
INSERT INTO movie_votes (user_id, movie_id) VALUES (1, 2);
```

donde el usuario 1 ya votó por la película 2 anteriormente, se generará la excepción:

```
ERROR:  Duplicate vote not allowed
```
