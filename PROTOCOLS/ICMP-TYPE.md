| Тип | Код | Название                                  | Описание                                                                 |
|-----|-----|--------------------------------------------|--------------------------------------------------------------------------|
| 0   | 0   | Echo Reply                                | Ответ на ping (ICMP echo request)                                        |
| 3   | 0   | Destination Unreachable: Network          | Сеть недоступна                                                          |
| 3   | 1   | Destination Unreachable: Host             | Хост недоступен                                                          |
| 3   | 2   | Destination Unreachable: Protocol         | Протокол недоступен                                                      |
| 3   | 3   | Destination Unreachable: Port             | Порт недоступен (чаще всего при UDP)                                     |
| 3   | 4   | Fragmentation Needed                      | Требуется фрагментация, но установлен флаг Don't Fragment                |
| 3   | 5   | Source Route Failed                       | Сбой маршрута                                                            |
| 3   | 6   | Destination Network Unknown               | Сеть назначения неизвестна                                               |
| 3   | 7   | Destination Host Unknown                  | Хост назначения неизвестен                                               |
| 3   | 8   | Source Host Isolated                      | Исходный хост изолирован                                                 |
| 3   | 9   | Network Admin Prohibited                  | Администр. запрет на сеть                                                |
| 3   | 10  | Host Admin Prohibited                     | Администр. запрет на хост                                                |
| 3   | 11  | Network Unreachable for ToS               | Недоступность сети для ToS                                               |
| 3   | 12  | Host Unreachable for ToS                  | Недоступность хоста для ToS                                              |
| 3   | 13  | Communication Administratively Prohibited | Связь запрещена администратором                                          |
| 3   | 14  | Host Precedence Violation                 | Нарушение приоритета хоста                                               |
| 3   | 15  | Precedence Cutoff in Effect               | Отсечка по приоритету включена                                           |
| 4   | 0   | Source Quench                             | Устаревшее сообщение об перегрузке (устаревшее)                          |
| 5   | 0   | Redirect: Network                         | Перенаправление по сети                                                  |
| 5   | 1   | Redirect: Host                            | Перенаправление к хосту                                                  |
| 5   | 2   | Redirect: ToS and Network                 | Перенаправление с ToS по сети                                            |
| 5   | 3   | Redirect: ToS and Host                    | Перенаправление с ToS по хосту                                           |
| 8   | 0   | Echo Request                              | Запрос ping                                                              |
| 9   | -   | Router Advertisement                      | Рекламное сообщение маршрутизатора                                       |
| 10  | -   | Router Solicitation                       | Запрос маршрутизатора                                                    |
| 11  | 0   | Time Exceeded in Transit                  | Истекло время TTL                                                        |
| 11  | 1   | Fragment Reassembly Time Exceeded         | Время на сборку фрагментов истекло                                       |
| 12  | 0   | Parameter Problem: Bad Header             | Проблема в заголовке пакета                                              |
| 12  | 1   | Parameter Problem: Missing Option         | Отсутствует обязательный параметр                                        |
| 12  | 2   | Parameter Problem: Bad Length             | Неправильная длина                                                       |
| 13  | 0   | Timestamp Request                         | Запрос временной метки                                                   |
| 14  | 0   | Timestamp Reply                           | Ответ с временной меткой                                                 |
| 15  | 0   | Information Request                       | Устаревшее — Запрос информации                                           |
| 16  | 0   | Information Reply                         | Устаревшее — Ответ на запрос информации                                  |
| 17  | 0   | Address Mask Request                      | Запрос маски адреса (устаревшее)                                         |
| 18  | 0   | Address Mask Reply                        | Ответ маски адреса                                                       |
