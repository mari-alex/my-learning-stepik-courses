-- 2.4 База данных «Интернет-магазин книг», запросы на выборку
-- Предметная область: https://stepik.org/lesson/308891/step/1?unit=291017


-- Задание 1
-- Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал)
 --в отсортированном по номеру заказа и названиям книг виде.

SELECT
  buy.buy_id,
  title,
  price,
  buy_book.amount
FROM
  client
  INNER JOIN buy USING(client_id)
  INNER JOIN buy_book USING(buy_id)
  INNER JOIN book USING(book_id)
WHERE
  name_client = 'Баранов Павел'
ORDER BY
  buy_id,
  book.title;

-- Задание 2
-- Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора
--(нужно посчитать, в каком количестве заказов фигурирует каждая книга).
--Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество.
--Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.

SELECT
  name_author,
  title,
  COUNT(buy_book.amount) AS 'Количество'
FROM
  author
  INNER JOIN book USING(author_id)
  LEFT JOIN buy_book USING(book_id)
GROUP BY
  book.title,
  name_author
ORDER BY
  name_author,
  title;

-- Задание 3
-- Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине.
--Указать количество заказов в каждый город, этот столбец назвать Количество.
--Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.

SELECT
  name_city,
  COUNT(buy_id) AS 'Количество'
FROM
  city
  INNER JOIN client ON city.city_id = client.city_id
  INNER JOIN buy ON client.client_id = buy.client_id
GROUP BY
  name_city
ORDER BY
  name_city ASC;

-- Задание 4
-- Вывести номера всех оплаченных заказов и даты, когда они были оплачены.

  SELECT
  buy_step.buy_id,
  date_step_end
FROM
  buy_step
  INNER JOIN step ON buy_step.step_id = step.step_id
WHERE
  buy_step.step_id = 1
  AND date_step_end IS NOT NULL;

-- Задание 5
-- Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость
--(сумма произведений количества заказанных книг и их цены), в отсортированном по номеру заказа виде.
--Последний столбец назвать Стоимость.

SELECT
  buy_id,
  name_client,
  SUM(book.price * buy_book.amount) AS 'Стоимость'
FROM
  buy_book
  JOIN buy using(buy_id)
  JOIN client using(client_id)
  JOIN book using(book_id)
GROUP BY
  buy_id,
  name_client
ORDER BY
  buy_id;

-- Задание 6
--Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся.
--Если заказ доставлен –  информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id.

SELECT
  buy_id,
  name_step
FROM
  step
  INNER JOIN buy_step ON step.step_id = buy_step.step_id
WHERE
  date_step_beg IS NOT NULL
  AND date_step_end IS NULL
ORDER BY
  buy_id;

--Задание 7
--В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (
--рассматривается только этап Транспортировка). Для тех заказов, которые прошли этап транспортировки,
--вывести количество дней за которое заказ реально доставлен в город.
--А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0.
--В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание.
--Информацию вывести в отсортированном по номеру заказа виде.

SELECT
  buy_id,
  DATEDIFF(date_step_end, date_step_beg) AS Количество_дней,
  CASE WHEN (
    DATEDIFF(date_step_end, date_step_beg)- days_delivery
  ) < 1 THEN 0 ELSE (
    DATEDIFF(date_step_end, date_step_beg)- days_delivery
  ) END AS Опоздание
FROM
  city
  JOIN client USING (city_id)
  JOIN buy USING (client_id)
  JOIN buy_step USING (buy_id)
  JOIN step USING (step_id)
WHERE
  name_step LIKE 'Транспортировка'
  AND date_step_end IS NOT NULL;


--Задание 8
-- Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде.
 --В решении используйте фамилию автора, а не его id.

SELECT
  DISTINCT name_client
FROM
  client
  JOIN buy USING(client_id)
  JOIN buy_book USING(buy_id)
  JOIN book USING(book_id)
  JOIN author USING(author_id)
WHERE
  author.name_author LIKE 'Достоевский Ф.М.'
ORDER BY
  name_client;
--Задание 9
--Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество.
--Последний столбец назвать Количество.

SELECT
  name_genre,
  SUM(buy_book.amount) as Количество
FROM
  genre
 JOIN book using(genre_id)
 JOIN buy_book using(book_id)
GROUP BY
  name_genre
HAVING
  SUM(buy_book.amount) = (
    SELECT
      MAX(total) AS amount
    FROM
      (
        SELECT
          genre_id,
          SUM(buy_book.amount) AS total
        FROM
          book
          JOIN buy_book using(book_id)
        GROUP BY
          genre_id
      ) t
  );



--Задание 10
--Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год,
--месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде.
--Название столбцов: Год, Месяц, Сумма.


SELECT
  YEAR(date_payment) AS Год,
  MONTHNAME(date_payment) AS Месяц,
  SUM(price * amount) AS Сумма
FROM
  buy_archive
GROUP BY
  Год,
  Месяц
UNION ALL
SELECT
  YEAR(date_step_end) AS Год,
  MONTHNAME(date_step_end) AS Месяц,
  SUM(price * buy_book.amount) AS Сумма
FROM
  buy_step
  INNER JOIN buy_book USING(buy_id)
  INNER JOIN book USING(book_id)
WHERE
  date_step_end IS NOT NULL
  AND step_id = 1
GROUP BY
  Год,
  Месяц
ORDER BY
  Месяц ASC,
  Год ASC;

--Задание 11
--Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости
--за 2020 и 2019 год . Вычисляемые столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию стоимости.

SELECT
  title,
  SUM(Количество) AS Количество,
  SUM(Сумма) AS Сумма
FROM
  (
    SELECT
      title,
      SUM(buy_book.amount) AS Количество,
      SUM(price * buy_book.amount) AS Сумма
    FROM
      book
       JOIN buy_book USING(book_id)
       JOIN buy_step USING(buy_id)
       JOIN step USING(step_id)
    WHERE
      name_step = 'Оплата'
      AND date_step_end IS NOT Null
    GROUP BY
      title,
      book_id
    UNION
    SELECT
      title,
      SUM(buy_archive.amount) AS Количество,
      SUM(
        buy_archive.price * buy_archive.amount
      ) AS Сумма
    FROM
      buy_archive
       JOIN book USING(book_id)
    GROUP BY
      title,
      book_id
  ) t
GROUP BY
 title
ORDER BY
 Сумма DESC;








