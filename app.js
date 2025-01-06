let map; // инстанс карт

document.addEventListener('DOMContentLoaded', () => {
    const regionInput = document.getElementById('regionInput');
    const suggestionList = document.getElementById('suggestionList');
    const stopInput = document.getElementById('stopInput');
    const stopSuggestionList = document.getElementById('stopSuggestionList');
    const clearButton = document.getElementById('clearButton');
    let selectedStopArea = null; // сюда выбранный stop_area
    let allStops = []; // список всех остановокб загружается изначальнр
    let marker = null; // текущая точка на карте

    const initMap = () => {
        map = new google.maps.Map(document.getElementById('map'), {
            center: { lat: 58.377983, lng: 26.729038 }, // начальный центр на Тарту
            zoom: 12,
        });
    };

    // доступ для google api
    window.initMap = initMap;

    // автозаполнение для регионов
    regionInput.addEventListener('input', () => {
        const query = regionInput.value.trim();

        if (query.length > 0) {
            fetch(`http://localhost:3000/regions?query=${query}`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Ошибка сети');
                    }
                    return response.json();
                })
                .then(data => {
                    suggestionList.innerHTML = ''; // очищаю старые подсказки

                    data.forEach(region => {
                        const option = document.createElement('li');
                        option.textContent = region;
                        option.className = 'simple-item';

                        // кликаю на регион и запоминаю выбор
                        option.addEventListener('click', () => {
                            regionInput.value = region;
                            suggestionList.innerHTML = ''; // очищаю список подсказок

                            selectedStopArea = region; // запоминаю выбранный регион

                            stopInput.value = ''; // очищаю поле остановки
                            stopSuggestionList.innerHTML = ''; // очищаю подсказки остановок
                        });

                        suggestionList.appendChild(option);
                    });
                })
                .catch(error => {
                    console.error('Ошибка получения регионов:', error);
                });
        } else {
            suggestionList.innerHTML = ''; // если ничего не ввел, очищаю подсказки
        }
    });

    // загружаю все остановки при загрузке страницы
    const fetchAllStops = () => {
        fetch('http://localhost:3000/stops')
            .then(response => {
                if (!response.ok) {
                    throw new Error('Ошибка сети');
                }
                return response.json();
            })
            .then(data => {
                allStops = data; // сохраняю все остановки
            })
            .catch(error => {
                console.error('Ошибка загрузки остановок:', error);
            });
    };

    fetchAllStops(); // загружаю остановки сразу

    // автозаполнение для остановок
    stopInput.addEventListener('input', () => {
        const stopQuery = stopInput.value.trim();

        if (selectedStopArea && stopQuery.length > 0) {
            const filteredStops = allStops.filter(stop => 
                stop.stop_area === selectedStopArea && 
                stop.stop_name.toLowerCase().includes(stopQuery.toLowerCase())
            );

            stopSuggestionList.innerHTML = ''; // очищаю старые подсказки

            filteredStops.forEach(stop => {
                const option = document.createElement('li');
                option.textContent = stop.stop_name;
                option.className = 'simple-item';

                // клик на остановку и обновять карту
                option.addEventListener('click', () => {
                    stopInput.value = stop.stop_name; // заполняю имя остановки
                    stopSuggestionList.innerHTML = ''; // очищ подсказки

                    if (stop.latitude && stop.longitude) {
                        const position = { lat: parseFloat(stop.latitude), lng: parseFloat(stop.longitude) };

                        console.log('Перемещаю карту на:', position); // проверяю позицию

                        map.setCenter(position);
                        map.setZoom(15);

                        if (marker) {
                            marker.setMap(null); // удалить старый маркер
                        }

                        marker = new google.maps.Marker({
                            position,
                            map,
                            title: stop.stop_name,
                        });
                    } else {
                        console.error('Нет координат для остановки:', stop);
                    }
                });

                stopSuggestionList.appendChild(option);
            });
        } else {
            stopSuggestionList.innerHTML = ''; // очищаю, если ничего не найдено
        }
    });

    // кнопка для очистки полей и карты
    clearButton.addEventListener('click', () => {
        regionInput.value = '';
        suggestionList.innerHTML = '';
        stopInput.value = '';
        stopSuggestionList.innerHTML = '';
        selectedStopArea = null;

        map.setCenter({ lat: 58.377983, lng: 26.729038 }); // сбросить центрирование
        map.setZoom(12);

        if (marker) {
            marker.setMap(null); // убираю маркер
            marker = null;
        }
    });
});
