-- 1. Нарушение UNIQUE: попытка добавить пациента с уже существующим полисом ОМС
-- Ожидаемая ошибка: duplicate key value violates unique constraint "uq_patients_policy"
INSERT INTO patients (full_name, birth_date, phone_number, insurance_policy) 
VALUES ('Новый Пациент', '1999-01-01', '+79990000000', '1111222233334444');

-- 2. Нарушение CHECK: попытка добавить врача с отрицательным стажем
-- Ожидаемая ошибка: new row for relation "doctors" violates check constraint "chk_experience_positive"
INSERT INTO doctors (full_name, specialty_id, experience_years, room_number) 
VALUES ('Сидоров Сидор Сидорович', 1, -2, '105');

-- 3. Нарушение CHECK: попытка установить записи несуществующий статус
-- Ожидаемая ошибка: new row for relation "appointments" violates check constraint "chk_status_valid"
UPDATE appointments SET status = 'in_progress' WHERE id = 1;

-- 4. Нарушение составного UNIQUE: попытка записать пациента к врачу на уже занятое время
-- Ожидаемая ошибка: duplicate key value violates unique constraint "uq_doctor_schedule"
INSERT INTO appointments (patient_id, doctor_id, appointment_timestamp, status) 
VALUES (3, 1, '2026-10-10 10:00:00', 'scheduled');

-- 5. Нарушение ссылочной целостности (ON DELETE RESTRICT): попытка удалить специальность, у которой есть врачи
-- Ожидаемая ошибка: update or delete on table "specialties" violates foreign key constraint "fk_doctor_specialty"
DELETE FROM specialties WHERE id = 1;