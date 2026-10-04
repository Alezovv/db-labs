-- Удаляем таблицы, если они существуют, чтобы скрипт можно было запускать многократно
DROP TABLE IF EXISTS medical_records CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS patients CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS specialties CASCADE;

-- 1. Справочник специальностей
CREATE TABLE specialties (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    -- Ограничение UNIQUE №1
    CONSTRAINT uq_specialties_name UNIQUE (name)
);

-- 2. Врачи
CREATE TABLE doctors (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    specialty_id INT NOT NULL,
    experience_years INT NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    
    -- Связь с правилом ON DELETE RESTRICT (нельзя удалить специальность, если есть врачи)
    CONSTRAINT fk_doctor_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE RESTRICT,
    
    -- Ограничение CHECK №1
    CONSTRAINT chk_experience_positive CHECK (experience_years >= 0)
);

-- 3. Пациенты
CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    insurance_policy VARCHAR(16) NOT NULL,
    
    -- Ограничение UNIQUE №2
    CONSTRAINT uq_patients_policy UNIQUE (insurance_policy),
    -- Дополнительный UNIQUE для телефона
    CONSTRAINT uq_patients_phone UNIQUE (phone_number),
    
    -- Ограничение CHECK №2
    CONSTRAINT chk_valid_birth_date CHECK (birth_date <= CURRENT_DATE)
);

-- 4. Записи на прием (основная связующая таблица)
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_timestamp TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    
    -- Правила ON DELETE
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
    
    -- Ограничение CHECK №3
    CONSTRAINT chk_status_valid CHECK (status IN ('scheduled', 'completed', 'cancelled')),
    
    -- Составное ограничение UNIQUE: врач не может принять двух пациентов одновременно
    CONSTRAINT uq_doctor_schedule UNIQUE (doctor_id, appointment_timestamp)
);

-- 5. Медицинские карты (результаты приемов)
CREATE TABLE medical_records (
    id SERIAL PRIMARY KEY,
    appointment_id INT NOT NULL,
    diagnosis TEXT NOT NULL,
    treatment TEXT NOT NULL,
    record_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    CONSTRAINT fk_record_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    -- Делаем связь строго 1 к 1 (на один прием - одна запись в карту)
    CONSTRAINT uq_record_appointment UNIQUE (appointment_id)
);