# 🗄️ Структура базы данных

## Основные таблицы

### crime_scene_report
- `date` - дата преступления
- `type` - тип преступления
- `description` - описание
- `city` - город

### person
- `id` - уникальный идентификатор
- `name` - имя человека
- `license_id` - ссылка на водительские права
- `address_street_name` - улица
- `address_number` - номер дома
- `ssn` - ИНН

### drivers_license
- `id` - уникальный идентификатор
- `age` - возраст
- `height` - рост
- `hair_color` - цвет волос
- `eye_color` - цвет глаз
- `gender` - пол
- `car_make` - марка автомобиля
- `car_model` - модель автомобиля
- `plate number` - номерной знак

### income
- `ssn` - ИНН
- `annual income` - годовой доход

### get_fit_now_member
- `id` - номер карты члена спортзала
- `person_id` - ссылка на person
- `name` - имя члена спортзала
- `membership_start_date` - дата начала членства
- `membership_status` - статус (gold/silver)

### get_fit_now_check_in
- `membership_id` - номер карты члена спортзала
- `check_in_date` - дата захода в спортзал
- `check_in_time` - время захода в спортзал
- `check_out_time` - время выхода из спортзала

### interview
- `person_id` - ссылка на person
- `transcript` - текст показаний

### facebook_event_chekin
- `person_id` - ссылка на person
- `event_id` - уникальный идентификатор
- `event_name` - название события
- `date` - дата события
