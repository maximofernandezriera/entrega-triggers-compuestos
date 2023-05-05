CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  salary INTEGER,
  job_title VARCHAR(50)
);

INSERT INTO employees (name, salary, job_title) VALUES ('Juan Pérez', 50000, 'Developer');
