## **Таблица маршрутов API для платформы Onlearn**

### **Группа 1: Аутентификация и авторизация**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Гость | Регистрация на платформе | `/api/auth/register` | POST | Нет | **Тело запроса:** `{ "email": "...", "password": "...", "name": "...", "role": "student" }`<br>**Ответ 201:** `{ "id": "uuid", "email": "...", "token": "jwt-token" }` |
| Гость | Вход в систему | `/api/auth/login` | POST | Нет | **Тело запроса:** `{ "email": "...", "password": "..." }`<br>**Ответ 200:** `{ "token": "jwt-token", "user": { ... } }` |
| Все | Восстановление пароля | `/api/auth/forgot-password` | POST | Нет | **Тело запроса:** `{ "email": "..." }`<br>**Ответ 200:** `{ "message": "Инструкции отправлены на email" }` |
| Все | Выход из системы | `/api/auth/logout` | POST | Да | **Заголовок:** `Authorization: Bearer {token}`<br>**Ответ 200:** `{ "message": "Выход выполнен" }` |

---

### **Группа 2: Управление пользователями и профилями**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Администратор | Управление пользователями | `/api/admin/users` | GET | Да (только admin) | **Ответ 200:** `{ "users": [ { "id": "...", "email": "...", "role": "...", "created_at": "..." }, ... ] }` |
| Администратор | Управление пользователями | `/api/admin/users/{user_id}` | PUT | Да (только admin) | **Тело запроса:** `{ "role": "teacher", "is_active": false }`<br>**Ответ 200:** `{ "message": "Пользователь обновлен" }` |
| Администратор | Управление пользователями | `/api/admin/users/{user_id}` | DELETE | Да (только admin) | **Ответ 200:** `{ "message": "Пользователь удален" }` |
| Все | Получение профиля | `/api/users/me` | GET | Да | **Заголовок:** `Authorization: Bearer {token}`<br>**Ответ 200:** `{ "user": { ... }, "profile": { ... } }` |
| Все | Обновление профиля | `/api/users/me/profile` | PATCH | Да | **Тело запроса:** `{ "avatar_url": "...", "bio": "...", "preferences": { ... } }`<br>**Ответ 200:** `{ "profile": { ... } }` |

---

### **Группа 3: Управление курсами (поиск, просмотр, запись)**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Гость, Студент | Поиск и фильтрация курсов | `/api/courses` | GET | Нет (для гостей) / Да (для студентов) | **Параметры запроса:** `?search=html&level=beginner&category=programming&page=1&limit=10`<br>**Ответ 200:** `{ "courses": [ ... ], "total": 150, "page": 1 }` |
| Студент | Просмотр деталей курса | `/api/courses/{course_id}` | GET | Да | **Ответ 200:** `{ "course": { ... }, "teacher": { ... }, "lessons_count": 15, "enrolled": false }` |
| Студент | Запись на курс | `/api/courses/{course_id}/enroll` | POST | Да | **Ответ 201:** `{ "enrollment": { ... }, "message": "Вы успешно записались на курс" }` |
| Студент | Отмена записи на курс | `/api/courses/{course_id}/enroll` | DELETE | Да | **Ответ 200:** `{ "message": "Запись на курс отменена" }` |
| Преподаватель | Создание курса | `/api/courses` | POST | Да (только teacher/admin) | **Тело запроса:** `{ "title": "...", "description": "...", "category": "...", "level": "beginner", "duration_hours": 40 }`<br>**Ответ 201:** `{ "course": { ... } }` |
| Преподаватель | Редактирование курса | `/api/courses/{course_id}` | PUT | Да (только teacher курса или admin) | **Тело запроса:** `{ "title": "...", "description": "...", ... }`<br>**Ответ 200:** `{ "course": { ... } }` |
| Администратор | Управление категориями | `/api/admin/categories` | GET | Да (только admin) | **Ответ 200:** `{ "categories": [ ... ] }` |
| Администратор | Управление категориями | `/api/admin/categories` | POST | Да (только admin) | **Тело запроса:** `{ "name": "Программирование", "parent_id": null }`<br>**Ответ 201:** `{ "category": { ... } }` |

---

### **Группа 4: Управление уроками и материалами**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Студент | Просмотр видеоурока | `/api/courses/{course_id}/lessons/{lesson_id}` | GET | Да (только для enrolled студентов) | **Ответ 200:** `{ "lesson": { ... }, "materials": [ ... ], "video_url": "...", "subtitles_url": "..." }` |
| Студент | Отметка урока как пройденного | `/api/courses/{course_id}/lessons/{lesson_id}/complete` | POST | Да (только для enrolled студентов) | **Ответ 200:** `{ "message": "Урок отмечен как пройденный", "progress": 25 }` |
| Студент | Скачивание материалов | `/api/courses/{course_id}/lessons/{lesson_id}/materials/{material_id}/download` | GET | Да (только для enrolled студентов) | **Ответ:** Файл для скачивания (Content-Disposition) |
| Преподаватель | Создание урока | `/api/courses/{course_id}/lessons` | POST | Да (только teacher курса или admin) | **Тело запроса:** `{ "title": "...", "type": "video", "content_url": "...", "order_index": 1 }`<br>**Ответ 201:** `{ "lesson": { ... } }` |
| Преподаватель | Загрузка материалов | `/api/courses/{course_id}/lessons/{lesson_id}/materials` | POST | Да (только teacher курса или admin) | **Content-Type:** `multipart/form-data`<br>**Поля:** `file`, `title`, `type`<br>**Ответ 201:** `{ "material": { ... } }` |
| Преподаватель | Редактирование урока | `/api/courses/{course_id}/lessons/{lesson_id}` | PUT | Да (только teacher курса или admin) | **Тело запроса:** `{ "title": "...", "content_url": "..." }`<br>**Ответ 200:** `{ "lesson": { ... } }` |

---

### **Группа 5: Управление тестами и заданиями**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Студент | Прохождение теста | `/api/courses/{course_id}/tests/{test_id}/attempt` | POST | Да (только для enrolled студентов) | **Тело запроса:** `{ "answers": [ { "question_id": 1, "answer": "A" }, ... ], "started_at": "timestamp" }`<br>**Ответ 201:** `{ "attempt": { ... }, "score": 85, "is_passed": true }` |
| Студент | Получение результатов теста | `/api/courses/{course_id}/tests/{test_id}/attempts/{attempt_id}` | GET | Да (только для enrolled студентов) | **Ответ 200:** `{ "attempt": { ... }, "questions": [ ... ] }` |
| Студент | Выполнение задания | `/api/courses/{course_id}/assignments/{assignment_id}/submit` | POST | Да (только для enrolled студентов) | **Content-Type:** `multipart/form-data` или `application/json`<br>**Поля:** `solution_text` или `solution_file`<br>**Ответ 201:** `{ "submission": { ... } }` |
| Преподаватель | Создание теста | `/api/courses/{course_id}/tests` | POST | Да (только teacher курса или admin) | **Тело запроса:** `{ "title": "...", "questions": [ { "text": "...", "type": "multiple_choice", "options": [ ... ], "correct_answer": "A" } ], "passing_score": 70 }`<br>**Ответ 201:** `{ "test": { ... } }` |
| Преподаватель | Проверка заданий | `/api/courses/{course_id}/assignments/{assignment_id}/submissions` | GET | Да (только teacher курса или admin) | **Ответ 200:** `{ "submissions": [ ... ] }` |
| Преподаватель | Проверка заданий | `/api/courses/{course_id}/assignments/{assignment_id}/submissions/{submission_id}/grade` | POST | Да (только teacher курса или admin) | **Тело запроса:** `{ "score": 95, "feedback": "Отличная работа!", "is_passed": true }`<br>**Ответ 200:** `{ "submission": { ... } }` |
| Преподаватель | Выставление оценок | `/api/courses/{course_id}/grades` | GET | Да (только teacher курса или admin) | **Ответ 200:** `{ "grades": [ ... ], "statistics": { ... } }` |

---

### **Группа 6: Прогресс, сертификаты и аналитика**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Студент | Отслеживание прогресса обучения | `/api/courses/{course_id}/progress` | GET | Да (только для enrolled студентов) | **Ответ 200:** `{ "progress": { ... }, "completed_lessons": 5, "total_lessons": 15, "percentage": 33.3 }` |
| Студент | Получение сертификата | `/api/courses/{course_id}/certificate` | GET | Да (только для completed студентов) | **Ответ 200:** `{ "certificate": { ... }, "download_url": "...", "verification_code": "..." }` |
| Студент | Получение всех сертификатов | `/api/users/me/certificates` | GET | Да | **Ответ 200:** `{ "certificates": [ ... ] }` |
| Преподаватель | Анализ успеваемости | `/api/courses/{course_id}/analytics/performance` | GET | Да (только teacher курса или admin) | **Ответ 200:** `{ "statistics": { "average_score": 78, "completion_rate": 65, "student_progress": [ ... ] } }` |
| Администратор | Просмотр системной аналитики | `/api/admin/analytics` | GET | Да (только admin) | **Параметры запроса:** `?period=month&metric=active_users`<br>**Ответ 200:** `{ "metrics": { ... }, "charts": [ ... ] }` |

---

### **Группа 7: Форум и коммуникация**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Студент, Преподаватель | Общение на форуме | `/api/courses/{course_id}/forum/threads` | GET | Да (только для enrolled студентов/teachers) | **Ответ 200:** `{ "threads": [ ... ] }` |
| Студент, Преподаватель | Общение на форуме | `/api/courses/{course_id}/forum/threads` | POST | Да (только для enrolled студентов/teachers) | **Тело запроса:** `{ "title": "...", "content": "...", "lesson_id": null }`<br>**Ответ 201:** `{ "thread": { ... } }` |
| Студент, Преподаватель | Общение на форуме | `/api/courses/{course_id}/forum/threads/{thread_id}/comments` | POST | Да (только для enrolled студентов/teachers) | **Тело запроса:** `{ "content": "...", "parent_comment_id": null }`<br>**Ответ 201:** `{ "comment": { ... } }` |
| Преподаватель | Модерация форума | `/api/courses/{course_id}/forum/threads/{thread_id}` | PATCH | Да (только teacher курса или admin) | **Тело запроса:** `{ "is_pinned": true, "is_closed": false }`<br>**Ответ 200:** `{ "thread": { ... } }` |
| Преподаватель | Модерация форума | `/api/courses/{course_id}/forum/comments/{comment_id}` | DELETE | Да (только teacher курса или admin) | **Ответ 200:** `{ "message": "Комментарий удален" }` |

---

### **Группа 8: Вебинары и онлайн-мероприятия**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Преподаватель | Проведение вебинара | `/api/courses/{course_id}/webinars` | POST | Да (только teacher курса или admin) | **Тело запроса:** `{ "title": "...", "description": "...", "start_time": "2024-12-20T15:00:00Z", "duration_minutes": 90 }`<br>**Ответ 201:** `{ "webinar": { ... }, "meeting_url": "..." }` |
| Студент | Запись на вебинар | `/api/courses/{course_id}/webinars/{webinar_id}/register` | POST | Да (только для enrolled студентов) | **Ответ 200:** `{ "message": "Вы зарегистрированы на вебинар", "calendar_invite": "..." }` |
| Все | Получение списка предстоящих вебинаров | `/api/courses/{course_id}/webinars/upcoming` | GET | Да (только для enrolled студентов/teachers) | **Ответ 200:** `{ "webinars": [ ... ] }` |
| Преподаватель | Загрузка записи вебинара | `/api/courses/{course_id}/webinars/{webinar_id}/recording` | POST | Да (только teacher курса или admin) | **Тело запроса:** `{ "recording_url": "..." }`<br>**Ответ 200:** `{ "webinar": { ... } }` |

---

### **Группа 9: Уведомления и настройки**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Студент | Получение уведомлений | `/api/users/me/notifications` | GET | Да | **Параметры запроса:** `?unread_only=true&limit=20`<br>**Ответ 200:** `{ "notifications": [ ... ] }` |
| Студент | Отметка уведомлений как прочитанных | `/api/users/me/notifications/{notification_id}/read` | POST | Да | **Ответ 200:** `{ "notification": { ... } }` |
| Все | Настройка уведомлений | `/api/users/me/notification-settings` | GET | Да | **Ответ 200:** `{ "settings": { "email": true, "push": true, ... } }` |
| Все | Настройка уведомлений | `/api/users/me/notification-settings` | PATCH | Да | **Тело запроса:** `{ "email": false, "assignment_deadline": true }`<br>**Ответ 200:** `{ "settings": { ... } }` |

---

### **Группа 10: Администрирование и системные функции**

| Актор | Use Case | Маршрут (Endpoint) | HTTP-метод | Требуется аутентификация | Описание запроса/ответа |
|-------|----------|-------------------|------------|--------------------------|--------------------------|
| Администратор | Модерация контента | `/api/admin/content/moderation-queue` | GET | Да (только admin) | **Ответ 200:** `{ "items": [ ... ] }` |
| Администратор | Модерация контента | `/api/admin/content/{content_type}/{content_id}/approve` | POST | Да (только admin) | **Ответ 200:** `{ "message": "Контент одобрен" }` |
| Администратор | Управление платежами | `/api/admin/payments` | GET | Да (только admin) | **Параметры запроса:** `?status=completed&date_from=2024-01-01`<br>**Ответ 200:** `{ "payments": [ ... ], "total_revenue": 15000 }` |
| Администратор | Управление промо-материалами | `/api/admin/promotions/banners` | POST | Да (только admin) | **Content-Type:** `multipart/form-data`<br>**Поля:** `image`, `title`, `link`, `position`<br>**Ответ 201:** `{ "banner": { ... } }` |

---

## **Сводная таблица по группам маршрутов**

| Группа | Количество эндпоинтов | Базовый префикс | Основные методы | Примеры эндпоинтов |
|--------|----------------------|----------------|-----------------|-------------------|
| Аутентификация | 4 | `/api/auth` | POST | `/api/auth/register`, `/api/auth/login` |
| Пользователи | 5 | `/api/users`, `/api/admin/users` | GET, PUT, DELETE, PATCH | `/api/users/me`, `/api/admin/users/{id}` |
| Курсы | 8 | `/api/courses` | GET, POST, PUT, DELETE | `/api/courses`, `/api/courses/{id}/enroll` |
| Уроки | 6 | `/api/courses/{id}/lessons` | GET, POST, PUT | `/api/courses/{id}/lessons/{id}` |
| Тесты и задания | 8 | `/api/courses/{id}/tests`, `/api/courses/{id}/assignments` | GET, POST, PUT | `/api/courses/{id}/tests/{id}/attempt` |
| Прогресс и сертификаты | 5 | `/api/courses/{id}/progress`, `/api/courses/{id}/certificate` | GET, POST | `/api/courses/{id}/progress` |
| Форум | 5 | `/api/courses/{id}/forum` | GET, POST, PATCH, DELETE | `/api/courses/{id}/forum/threads` |
| Вебинары | 4 | `/api/courses/{id}/webinars` | GET, POST | `/api/courses/{id}/webinars` |
| Уведомления | 4 | `/api/users/me/notifications` | GET, POST, PATCH | `/api/users/me/notifications` |
| Администрирование | 5 | `/api/admin` | GET, POST, PUT, DELETE | `/api/admin/analytics` |

**Всего эндпоинтов: 54**

---
