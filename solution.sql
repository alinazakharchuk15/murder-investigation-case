-- =============================================
-- SQL MURDER MYSTERY SOLUTION
-- Author: [Твоё имя]
-- Date: [Дата решения]
-- =============================================

/*
РАССЛЕДОВАНИЕ УБИЙСТВА В SQL CITY
Задача: найти убийцу и раскрыть заказчика
*/

-- === ЭТАП 1: ПОИСК СВИДЕТЕЛЕЙ ===

-- Анализ отчёта о преступлении
SELECT * 
FROM crime_scene_report
WHERE type = 'murder' 
  AND city = 'SQL City' 
  AND date = 20180115;

/* РЕЗУЛЬТАТ:
Security footage shows that there were 2 witnesses. 
The first witness lives at the last house on "Northwestern Dr". 
The second witness, named Annabel, lives somewhere on "Franklin Ave".
*/

-- Поиск первого свидетеля (последний дом на Northwestern Dr)
SELECT * 
FROM person p 
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;
-- Найден: Morty Schapiro (id: 14887)

-- Поиск второго свидетеля (Annabel на Franklin Ave)
SELECT * 
FROM person p 
WHERE address_street_name = 'Franklin Ave' 
  AND name LIKE '%Annabel%';
-- Найдена: Annabel Miller (id: 16371)

-- === ЭТАП 2: ОПРОС СВИДЕТЕЛЕЙ ===

-- Получение показаний свидетелей
SELECT p.name, i.transcript
FROM interview i 
JOIN person p ON i.person_id = p.id
WHERE p.name IN ('Annabel Miller', 'Morty Schapiro');

/* ПОКАЗАНИЯ:
Morty Schapiro:
- Слышал выстрел, видел мужчину с сумкой спортзала "Get Fit Now Gym"
- Номер членской карты начинался с "48Z", только у gold-членов такие сумки
- Номер машины содержал "H42W"

Annabel Miller:
- Узнала убийцу из спортзала, видела его 9 января
*/

-- === ЭТАП 3: ПОИСК ИСПОЛНИТЕЛЯ ===

-- Поиск по описанию от свидетелей
SELECT 
    p.name,
    p.address_street_name,
    p.address_number,
    gfnm.id as membership_id,
    dl.plate_number
FROM person p 
LEFT JOIN get_fit_now_member gfnm ON p.id = gfnm.person_id 
LEFT JOIN get_fit_now_check_in gfnci ON gfnm.id = gfnci.membership_id
LEFT JOIN drivers_license dl ON p.license_id = dl.id
WHERE gfnci.membership_id LIKE '48Z%'           -- Номер членства начинается с 48Z
  AND gfnm.membership_status = 'gold'           -- Gold-член
  AND gfnci.check_in_date = 20180109            -- Был в спортзале 9 января
  AND dl.plate_number LIKE '%H42W%';            -- Номер машины содержит H42W

-- РЕЗУЛЬТАТ: Jeremy Bowers (id: 67318)

-- === ЭТАП 4: ПОИСК ЗАКАЗЧИКА ===

-- Получение показаний Jeremy Bowers
SELECT p.name, i.transcript
FROM interview i 
JOIN person p ON i.person_id = p.id
WHERE p.name = 'Jeremy Bowers';

/* ПОКАЗАНИЯ Jeremy Bowers:
- Найден женщиной с деньгами
- Примерно 5'5" (65") или 5'7" (67")
- Рыжие волосы, Tesla Model S
- Посещала SQL Symphony Concert 3 раза в декабре 2017
*/

-- Поиск по внешности и автомобилю
SELECT p.id, p.name, dl.height, dl.hair_color, dl.car_make, dl.car_model
FROM person p 
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.gender = 'female' 
  AND dl.car_make = 'Tesla' 
  AND dl.car_model = 'Model S'
  AND dl.hair_color = 'red' 
  AND dl.height BETWEEN 65 AND 67;

-- Найдены кандидаты: Red Korb (id: 78881) и Miranda Priestly (id: 99716)

-- Проверка посещения концертов
SELECT p.name, COUNT(*) as concert_visits
FROM facebook_event_checkin fec 
JOIN person p ON p.id = fec.person_id
WHERE fec.event_name LIKE '%SQL Symphony Concert%' 
  AND fec.date LIKE '201712%'
GROUP BY p.name
HAVING COUNT(*) = 3;

-- Посещали 3 раза: Miranda Priestly и Bryan Pardo

-- Сравнение кандидатов
SELECT 
    p.name,
    dl.height,
    dl.hair_color,
    dl.car_make,
    dl.car_model,
    COUNT(fec.event_name) as concert_visits
FROM person p 
LEFT JOIN drivers_license dl ON p.license_id = dl.id
LEFT JOIN facebook_event_checkin fec ON p.id = fec.person_id 
    AND fec.event_name LIKE '%SQL Symphony Concert%' 
    AND fec.date LIKE '201712%'
WHERE p.name IN ('Miranda Priestly', 'Red Korb', 'Bryan Pardo')
GROUP BY p.name, dl.height, dl.hair_color, dl.car_make, dl.car_model;

/* ВЫВОД:
Miranda Priestly и Red Korb имеют одинаковые параметры внешности и автомобиль.
Red Korb не посещала концерты - это фальшивая личность Miranda Priestly.
*/

-- === ФИНАЛЬНОЕ РЕШЕНИЕ ===
INSERT INTO solution VALUES (1, 'Miranda Priestly');

SELECT value FROM solution;
-- Результат: "Congrats, you found the brains behind the murder!"
