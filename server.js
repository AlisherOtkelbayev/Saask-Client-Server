const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// подключаюсь к базе
db.connect((err) => {
  if (err) {
    console.error('Ошибка подключения к БД:', err);
    return;
  }
  console.log('Подключился к базе!');
});

// маршрут для всех остановок
app.get('/stops', (req, res) => {
  const query = 'SELECT * FROM stops';
  db.query(query, (err, results) => {
    if (err) {
      console.error('Ошибка получения остановок:', err);
      res.status(500).send('Ошибка сервера');
      return;
    }
    res.json(results); // возвращаю данные
  });
});

// маршрут для регионов
app.get('/regions', (req, res) => {
  const query = req.query.query; 
  const sql = 'SELECT DISTINCT stop_area FROM stops WHERE stop_area LIKE ? LIMIT 10';
  const values = [`%${query}%`];

  db.query(sql, values, (err, results) => {
    if (err) {
      console.error('Ошибка получения регионов:', err);
      res.status(500).send('Ошибка сервера');
      return;
    }
    res.json(results.map(row => row.stop_area)); // только имена регионов
  });
});

// маршрут для остановок в определенном регионе
app.get('/stops', (req, res) => {
    const stopArea = req.query.stop_area; 

    if (!stopArea) {
        res.status(400).send('Не указан параметр stop_area');
        return;
    }

    const sql = 'SELECT DISTINCT stop_name FROM stops WHERE stop_area = ?';
    db.query(sql, [stopArea], (err, results) => {
        if (err) {
            console.error('Ошибка получения остановок:', err);
            res.status(500).send('Ошибка сервера');
            return;
        }
        res.json(results.map(row => row.stop_name)); 
    });
});

// запуск сервера
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Сервер запущен: http://localhost:${PORT}`);
});
