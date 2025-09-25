-- =============================================
-- SQL MURDER MYSTERY SOLUTION
-- Author: Alina Zakharchuk
-- Date: 25.09.25
-- =============================================

/*
РАССЛЕДОВАНИЕ УБИЙСТВА В SQL CITY
Задача: найти убийцу, совершившего преступление 15.01.18
*/

-- === ЭТАП 1: ПОИСК СВИДЕТЕЛЕЙ ===

-- Анализ отчёта о преступлении
SELECT * FROM crime_scene_report
WHERE type = 'murder' AND city = 'SQL City' AND date=20180115;

/* РЕЗУЛЬТАТ:
Security footage shows that there were 2 witnesses. 
The first witness lives at the last house on "Northwestern Dr". 
The second witness, named Annabel, lives somewhere on "Franklin Ave".
*/

-- Поиск первого свидетеля (последний дом на Northwestern Dr)
SELECT * FROM person p 
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;
-- Найден: Morty Schapiro (id: 14887)

-- Поиск второго свидетеля (Annabel на Franklin Ave)
SELECT * FROM person p 
WHERE address_street_name = 'Franklin Ave' 
  AND name LIKE '%Annabel%';
-- Найдена: Annabel Miller (id: 16371)

-- === ЭТАП 2: ОПРОС СВИДЕТЕЛЕЙ ===

-- Получение показаний свидетелей
SELECT *
FROM 
	interview i JOIN person p ON i.person_id = p.id
WHERE name IN ('Annabel Miller', 'Morty Schapiro');

/* ПОКАЗАНИЯ:
Morty Schapiro:
- Слышал выстрел, видел мужчину с сумкой спортзала "Get Fit Now Gym"
- Номер клубной карты спортзала начинался с "48Z", только у gold-членов такие сумки
- Номер машины содержал "H42W"

Annabel Miller:
- Узнала убийцу из спортзала, видела его 9 января
*/

-- === ЭТАП 3: ПОИСК ИСПОЛНИТЕЛЯ ===

-- Поиск по описанию от свидетелей
SELECT p.name, 
  p.address_street_name, 
  p.address_number, 
  gfnm.id, 
  dl.plate_number
FROM 
	person p 
	LEFT JOIN get_fit_now_member gfnm  ON p.id = gfnm.person_id 
	LEFT JOIN get_fit_now_check_in gfnci ON gfnm.id = gfnci.membership_id
	LEFT JOIN drivers_license dl ON p.license_id = dl.id
WHERE gfnci.membership_id LIKE '%48Z%'          -- Номер членства начинается с 48Z
	AND gfnm.membership_status = 'gold'           -- Gold-член 
	AND gfnci.check_in_date = 20180109            -- Был в спортзале 9 января
	AND dl.plate_number LIKE '%H42W%';             -- Номер машины содержит H42W

-- РЕЗУЛЬТАТ: Jeremy Bowers (id: 67318)

-- === ЭТАП 4: ПОИСК ЗАКАЗЧИКА ===

-- Получение показаний Jeremy Bowers
SELECT *
FROM 
	interview i JOIN person p ON i.person_id = p.id
WHERE name IN ('Jeremy Bowers');

/* ПОКАЗАНИЯ Jeremy Bowers:
- Заказан женщиной с большим количеством денег
- Рост примерно 5'5" (65") или 5'7" (67")
- Рыжие волосы, водит автомобиль Tesla Model S
- Посещала SQL Symphony Concert 3 раза в декабре 2017
*/

-- Поиск по внешности и автомобилю
SELECT *
FROM 
	person p JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.gender = 'female' 
	AND dl.car_make = 'Tesla' 
	AND car_model LIKE '%S%' 
	AND dl.hair_color = 'red' 
	AND dl.height IN (65, 67);

-- Найдены кандидаты: Red Korb (id: 78881) и Miranda Priestly (id: 99716)

-- Проверка посещения концертов
SELECT p.name 
FROM 
	facebook_event_checkin fec JOIN person p ON p.id = fec.person_id
WHERE event_name LIKE '%SQL Symphony Concert%' AND date LIKE '201712%'
GROUP BY p.name
HAVING COUNT(*) = 3;

-- Посещали 3 раза: Miranda Priestly и Bryan Pardo

-- Сравнение кандидатов
SELECT *
FROM 
	person p 
	LEFT JOIN get_fit_now_member gfnm  ON p.id = gfnm.person_id 
	LEFT JOIN get_fit_now_check_in gfnci ON gfnm.id = gfnci.membership_id
	LEFT JOIN drivers_license dl ON p.license_id = dl.id
	LEFT JOIN facebook_event_checkin fec ON p.id = fec.person_id
WHERE p.name IN ('Bryan Pardo', 'Miranda Priestly') AND date LIKE '201712%';

SELECT *
FROM 
	person p 
	LEFT JOIN get_fit_now_member gfnm  ON p.id = gfnm.person_id 
	LEFT JOIN get_fit_now_check_in gfnci ON gfnm.id = gfnci.membership_id
	LEFT JOIN drivers_license dl ON p.license_id = dl.id
	LEFT JOIN facebook_event_checkin fec ON p.id = fec.person_id
WHERE p.name IN ('Red Korb', 'Miranda Priestly');

/* ВЫВОД:
Miranda Priestly и Red Korb имеют одинаковые параметры внешности и автомобиль.
Red Korb не посещала концерты - это фальшивая личность Miranda Priestly.
*/

-- Просмотр информации о Miranda Priestly и Red Korb
SELECT *
FROM 
	interview i 
	RIGHT JOIN person p ON i.person_id = p.id
	RIGHT JOIN income i2 USING (ssn)
WHERE name IN ('Red Korb', 'Miranda Priestly');

/* ВЫВОД:
Ни одной из двух личностей не было записано ни одно интервью. 
Часть доходов Miranda Priestly направляла на счет своей фальшивой личности 
*/

-- === ФИНАЛЬНОЕ РЕШЕНИЕ ===
INSERT INTO solution VALUES (1, 'Miranda Priestly');
SELECT * FROM solution s;

-- Результат: "Congrats, you found the brains behind the murder!"
