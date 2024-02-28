//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ
//
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	// Установка значения реквизита АдресКартинки.
	ФайлКартинки = Объект.ФайлКартинки;
	Если Не ФайлКартинки.Пустая() Тогда
		АдресКартинки = ПолучитьНавигационнуюСсылку(ФайлКартинки, "ДанныеФайла");
	КонецЕсли;

	ЗаполнитьХарактеристики();

	ОпределитьДоступнность(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	ЗаписатьХарактеристики();
	Установлен = Ложь;
	Если ПараметрыЗаписи.Свойство("Уведомление", Установлен) И Установлен Тогда
		Уведомление = Новый ДоставляемоеУведомление;
		Уведомление.Текст = НСтр("ru = 'Добавлен новый товар'", "ru");
		Уведомление.Данные = "1";
		Проблемы = Новый Массив;
		УведомленияСервер.ОтправитьУведомление(Уведомление, Неопределено, Проблемы);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	КартинкиИзменены = Ложь;
	КартинкиОписания.Очистить();
	Если Элементы.ГруппаРедактированияОписания.ТекущаяСтраница = Элементы.ГруппаРедактирование Тогда
		РедактироватьОписаниеСервер();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура УдалитьКартинкиОписания()

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Ссылка
	|ИЗ
	|	Справочник.ХранимыеФайлы
	|ГДЕ
	|	Владелец = &Владелец
	|	И ДляОписания = ИСТИНА";

	Запрос.УстановитьПараметр("Владелец", Объект.Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ФайлОбъект = Выборка.Ссылка.ПолучитьОбъект();
		Если ФайлОбъект <> Неопределено Тогда
			ФайлОбъект.Удалить();
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)

	Перем ТекстHTML;
	Перем Вложения;

	Если Элементы.ГруппаРедактированияОписания.ТекущаяСтраница = Элементы.ГруппаРедактирование Тогда

		РедактируемоеОписание.ПолучитьHTML(ТекстHTML, Вложения);
		СоответствиеАдресов = Новый Соответствие;

		УдалитьКартинкиОписания();
		Для Каждого Вложение Из Вложения Цикл

			ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
			ХранимыйФайл.Владелец = ТекущийОбъект.Ссылка;
			ХранимыйФайл.Наименование = Вложение.Ключ;
			ХранимыйФайл.ИмяФайла = Вложение.Ключ;
			ХранимыйФайл.ДляОписания = Истина;
			ДвоичныеДанные = Вложение.Значение.ПолучитьДвоичныеДанные();
			ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных);
			ХранимыйФайл.Записать();
			Адрес = ПолучитьНавигационнуюСсылку(ХранимыйФайл.Ссылка, "ДанныеФайла");
			СоответствиеАдресов.Вставить(Вложение.Ключ, Адрес);
		КонецЦикла;

		ПреобразоватьHTML(ТекстHTML, СоответствиеАдресов);

		ТекущийОбъект.Описание = ТекстHTML;

	ИначеЕсли КартинкиИзменены Тогда

		ТекстHTML = ТекущийОбъект.Описание;

		УдалитьКартинкиОписания();
		Для Каждого Картинка Из КартинкиОписания Цикл
			ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
			ХранимыйФайл.Владелец = ТекущийОбъект.Ссылка;
			ХранимыйФайл.Наименование = Картинка.Представление;
			ХранимыйФайл.ИмяФайла = Картинка.Представление;
			ХранимыйФайл.ДляОписания = Истина;
			ДвоичныеДанные = ПолучитьИзВременногоХранилища(Картинка.Значение);
			ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных);
			ХранимыйФайл.Записать();
			УдалитьИзВременногоХранилища(Картинка.Значение);
			Адрес = ПолучитьНавигационнуюСсылку(ХранимыйФайл.Ссылка, "ДанныеФайла");
			ТекстHTML = СтрЗаменить(ТекстHTML, Картинка.Значение, Адрес);
		КонецЦикла;

		ТекущийОбъект.Описание = ТекстHTML;
	КонецЕсли;
	КартинкиИзменены = Ложь;
	КартинкиОписания.Очистить();

	Если ТекущийОбъект.ЭтоНовый() Тогда
		ПараметрыЗаписи.Вставить("Уведомление", Истина);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ФайлКартинкиПриИзменении(Элемент)

	// Отслеживание изменения картинки и соответствующее обновление
	// реквизита АдресКартинки.
	ФайлКартинки = Объект.ФайлКартинки;
	Если Не ФайлКартинки.Пустая() Тогда
		АдресКартинки = ПолучитьНавигационнуюСсылку(ФайлКартинки, "ДанныеФайла");
	Иначе
		АдресКартинки = "";
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ВидПриИзменении(Элемент)
	ОпределитьДоступнность(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ФайлКартинкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	Если Объект.Ссылка.Пустая() Тогда
		ПоказатьПредупреждение( , НСтр("ru = 'Данные не записаны'", "ru"));
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;

КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////// 
// Процедуры и функции формы

//Расстановка признака доступность элементов в зависимости от того, редактируется  
//товар ИЛИ услуга
&НаКлиентеНаСервереБезКонтекста
Процедура ОпределитьДоступнность(Форма)

	ДоступностьРеквизитовТовара = Форма.Объект.Вид = ПредопределенноеЗначение("Перечисление.ВидыТоваров.Товар");
	Форма.Элементы.ШтрихКод.Доступность = ДоступностьРеквизитовТовара;
	Форма.Элементы.Поставщик.Доступность = ДоступностьРеквизитовТовара;
	Форма.Элементы.Артикул.Доступность = ДоступностьРеквизитовТовара;

КонецПроцедуры

&НаКлиенте
Процедура ДобавитьХарактеристику(Команда)
	
	//Выберем вид характеристики
	Оповещение = Новый ОписаниеОповещения("ДобавитьХарактеристикуЗавершение", ЭтотОбъект);
	ОткрытьФорму("ПланВидовХарактеристик.ВидыХарактеристик.ФормаВыбора", , , , , , Оповещение,
		РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьХарактеристикуЗавершение(ВидХарактеристики, Параметры) Экспорт
	Если ВидХарактеристики = Неопределено Тогда
		Возврат;
	КонецЕсли;	 
	
	//Проверим наличие 
	Если ОписаниеХарактеристик.НайтиСтроки(
		 Новый Структура("ВидХарактеристики", ВидХарактеристики)).Количество() > 0 Тогда
		ПоказатьПредупреждение( , НСтр("ru = 'Характеристика уже существует!'", "ru"));
		Возврат;
	КонецЕсли;	 
	
	//Добавим вид характеристики на форму
	ДобавитьХарактеристикуНаСервере(ВидХарактеристики);
КонецПроцедуры

&НаКлиенте
Процедура УдалитьХарактеристику(Команда)
	
	//Выберем удаляемый вид
	СписокВидов = Новый СписокЗначений;
	Для Каждого ОписаниеХарактеристики Из ОписаниеХарактеристик Цикл

		ЭлементСпискаВидов = СписокВидов.Добавить();
		ЭлементСпискаВидов.Значение = ОписаниеХарактеристики.ПолучитьИдентификатор();
		ЭлементСпискаВидов.Представление = Строка(ОписаниеХарактеристики.ВидХарактеристики);

	КонецЦикла;
	Оповещение = Новый ОписаниеОповещения("УдалитьХарактеристикуЗавершение", ЭтотОбъект);
	СписокВидов.ПоказатьВыборЭлемента(Оповещение, "Удалить характеристику:");

КонецПроцедуры

&НаКлиенте
Процедура УдалитьХарактеристикуЗавершение(ВыбранныйЭлемент, Параметры) Экспорт
	//Проверим выбор
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	//Выполним удаление
	УдалитьХарактеристикуНаСервере(ВыбранныйЭлемент.Значение);
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьХарактеристики()

	//Добавление реквизитов
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВидыХарактеристик.Ссылка,
	|	ВидыХарактеристик.Код,
	|	ВидыХарактеристик.Наименование,
	|	ВидыХарактеристик.ТипЗначения,
	|	Характеристики.Объект,
	|	Характеристики.ВидХарактеристики,
	|	Характеристики.Значение
	|ИЗ
	|	ПланВидовХарактеристик.ВидыХарактеристик КАК ВидыХарактеристик
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.Характеристики КАК Характеристики
	|		ПО (Характеристики.ВидХарактеристики = ВидыХарактеристик.Ссылка)
	|ГДЕ
	|	Характеристики.Объект = &Объект
	|АВТОУПОРЯДОЧИВАНИЕ";
	Запрос.УстановитьПараметр("Объект", Объект.Ссылка);
	Результат = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = Результат.Выбрать();
	ДобавляемыеРеквизиты = Новый Массив;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл

		Реквизит = Новый РеквизитФормы("Характеристика" + ВыборкаДетальныеЗаписи.Код,
			ВыборкаДетальныеЗаписи.ТипЗначения);
		Реквизит.СохраняемыеДанные = Истина;
		ДобавляемыеРеквизиты.Добавить(Реквизит);

	КонецЦикла;
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	//Добавление элементов, заполнение данных, добавление описания характеристики
	ВыборкаДетальныеЗаписи = Результат.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Элемент =Элементы.Добавить(
						  "Характеристика" + ВыборкаДетальныеЗаписи.Код, Тип("ПолеФормы"),
			Элементы.ГруппаХарактеристики);
		Элемент.Вид = ВидПоляФормы.ПолеВвода;
		Элемент.Заголовок = ВыборкаДетальныеЗаписи.Наименование;
		Элемент.ПутьКДанным = "Характеристика" + ВыборкаДетальныеЗаписи.Код;

		МассивПараметровВыбора = Новый Массив;
		МассивПараметровВыбора.Добавить(Новый ПараметрВыбора("Отбор.Владелец", ВыборкаДетальныеЗаписи.Ссылка));
		Элемент.ПараметрыВыбора = Новый ФиксированныйМассив(МассивПараметровВыбора);

		ОписаниеХарактеристики = ОписаниеХарактеристик.Добавить();
		ОписаниеХарактеристики.ВидХарактеристики = ВыборкаДетальныеЗаписи.Ссылка;
		ОписаниеХарактеристики.ИмяРеквизита = "Характеристика" + ВыборкаДетальныеЗаписи.Код;

		ЭтотОбъект["Характеристика" + ВыборкаДетальныеЗаписи.Код] = ВыборкаДетальныеЗаписи.Значение;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ДобавитьХарактеристикуНаСервере(ВидХарактеристики)
	
	//Добавление реквизита
	ДобавляемыеРеквизиты = Новый Массив;
	Реквизит = Новый РеквизитФормы("Характеристика" + ВидХарактеристики.Код, ВидХарактеристики.ТипЗначения);
	Реквизит.СохраняемыеДанные = Истина;
	ДобавляемыеРеквизиты.Добавить(Реквизит);
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	//Добавление элемента, заполнение данных
	Элемент =Элементы.Добавить(
					  "Характеристика" + ВидХарактеристики.Код, Тип("ПолеФормы"), Элементы.ГруппаХарактеристики);
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.Заголовок = ВидХарактеристики.Наименование;
	Элемент.ПутьКДанным = "Характеристика" + ВидХарактеристики.Код;

	МассивПараметровВыбора = Новый Массив;
	МассивПараметровВыбора.Добавить(Новый ПараметрВыбора("Отбор.Владелец", ВидХарактеристики));
	Элемент.ПараметрыВыбора = Новый ФиксированныйМассив(МассивПараметровВыбора);
	
	//Добавление описания характеристики
	ОписаниеХарактеристики = ОписаниеХарактеристик.Добавить();
	ОписаниеХарактеристики.ВидХарактеристики = ВидХарактеристики;
	ОписаниеХарактеристики.ИмяРеквизита = "Характеристика" + ВидХарактеристики.Код;
	
	//Новый элемент установим текущим
	ТекущийЭлемент = Элемент;

КонецПроцедуры

&НаСервере
Процедура УдалитьХарактеристикуНаСервере(Идентификатор)

	ОписаниеХарактеристики = ОписаниеХарактеристик.НайтиПоИдентификатору(Идентификатор);
	ИмяРеквизита = ОписаниеХарактеристики.ИмяРеквизита;
	
	//Удаление описания
	ОписаниеХарактеристик.Удалить(ОписаниеХарактеристики);
	
	//Удаление элемента
	Элементы.Удалить(Элементы.Найти(ИмяРеквизита));
	
	//Удаление реквизита
	УдаляемыеРеквизиты = Новый Массив;
	УдаляемыеРеквизиты.Добавить(ИмяРеквизита);
	ИзменитьРеквизиты( , УдаляемыеРеквизиты);
КонецПроцедуры

&НаСервере
Процедура ЗаписатьХарактеристики()

	//Сформируем набор записей с новыми значениями характеристик
	НаборЗаписей = РегистрыСведений.Характеристики.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(Объект.Ссылка);
	Для Каждого ОписаниеХарактеристики Из ОписаниеХарактеристик Цикл

		Запись = НаборЗаписей.Добавить();
		Запись.Объект = Объект.Ссылка;
		Запись.ВидХарактеристики = ОписаниеХарактеристики.ВидХарактеристики;
		Запись.Значение = ЭтотОбъект[ОписаниеХарактеристики.ИмяРеквизита];

	КонецЦикла;
	
	//Запишем набор записей
	НаборЗаписей.Записать();
	//	а = 1 / 0;

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьКартинку(Команда)

	Элементы.Картинка.Обновить();

КонецПроцедуры

&НаСервере
Процедура РедактироватьОписаниеСервер()

	ТекстHTML = Объект.Описание;
	Вложения = Новый Структура;

	Если КартинкиИзменены Тогда

		Для Каждого Картинка Из КартинкиОписания Цикл
			ТекстHTML = СтрЗаменить(ТекстHTML, Картинка.Значение, Картинка.Представление);
			ДвоичныеДанные = ПолучитьИзВременногоХранилища(Картинка.Значение);
			Вложения.Вставить(Картинка.Представление, Новый Картинка(ДвоичныеДанные));
		КонецЦикла;

	Иначе

		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Ссылка,
		|	ДанныеФайла
		|ИЗ
		|	Справочник.ХранимыеФайлы
		|ГДЕ
		|	Владелец = &Владелец
		|	И ДляОписания = ИСТИНА";

		Запрос.УстановитьПараметр("Владелец", Объект.Ссылка);
		Выборка = Запрос.Выполнить().Выбрать();
		НомерКартинки = 1;
		Пока Выборка.Следующий() Цикл
			Адрес = ПолучитьНавигационнуюСсылку(Выборка.Ссылка, "ДанныеФайла");
			Имя = "img" + НомерКартинки;
			НомерКартинки = НомерКартинки + 1;
			ТекстHTML = СтрЗаменить(ТекстHTML, Адрес, Имя);
			Вложения.Вставить(Имя, Новый Картинка(Выборка.ДанныеФайла.Получить()));
		КонецЦикла;

	КонецЕсли;

	РедактируемоеОписание.УстановитьHTML(ТекстHTML, Вложения);

КонецПроцедуры

&НаКлиенте
Процедура РедактироватьОписание(Команда)
	РедактироватьОписаниеСервер();
	Элементы.ГруппаРедактированияОписания.ТекущаяСтраница = Элементы.ГруппаРедактирование;
КонецПроцедуры

&НаСервере
Процедура ПреобразоватьHTML(ТекстHTML, СоответствиеАдресов)

	ЧтениеHTML = Новый ЧтениеHTML;
	ЧтениеHTML.УстановитьСтроку(ТекстHTML);

	ПостроительDOM = Новый ПостроительDOM;
	ДокументHTML = ПостроительDOM.Прочитать(ЧтениеHTML);
	
	// На мобильных устройствах описание должно отображаться реальным размером, без сжатия.
	Элемент = ДокументHTML.СоздатьЭлемент("meta");
	Элемент.УстановитьАтрибут("name", "viewport");
	Элемент.УстановитьАтрибут("content", "initial-scale=1.0, width=device-width");
	ЭлементыHead = ДокументHTML.ПолучитьЭлементыПоИмени("head");
	Head = ЭлементыHead.Элемент(0);
	Head.ВставитьПеред(Элемент, Head.ПервыйДочерний);
	
	// Преобразование адресов картинок
	ЭлементыImg = ДокументHTML.ПолучитьЭлементыПоИмени("img");
	Для Каждого Img Из ЭлементыImg Цикл
		НовыйАдрес = СоответствиеАдресов.Получить(Img.Источник);
		Если НовыйАдрес <> Неопределено Тогда
			Img.Источник = НовыйАдрес;
		КонецЕсли;
	КонецЦикла;

	ЗаписьHTML = Новый ЗаписьHTML;
	ЗаписьHTML.УстановитьСтроку();

	ЗаписьDOM = Новый ЗаписьDOM;
	ЗаписьDOM.Записать(ДокументHTML, ЗаписьHTML);

	ТекстHTML = ЗаписьHTML.Закрыть();

КонецПроцедуры

&НаСервере
Процедура ЗакончитьРедактированиеСервер()
	Перем ТекстHTML;
	Перем Вложения;
	КартинкиИзменены = Истина;
	КартинкиОписания.Очистить();
	РедактируемоеОписание.ПолучитьHTML(ТекстHTML, Вложения);
	СоответствиеАдресов = Новый Соответствие;

	Для Каждого Вложение Из Вложения Цикл
		Адрес = ПоместитьВоВременноеХранилище(Вложение.Значение.ПолучитьДвоичныеДанные(), УникальныйИдентификатор);
		КартинкиОписания.Добавить(Адрес, Вложение.Ключ);
		СоответствиеАдресов.Вставить(Вложение.Ключ, Адрес);
	КонецЦикла;

	ПреобразоватьHTML(ТекстHTML, СоответствиеАдресов);

	Объект.Описание = ТекстHTML;
КонецПроцедуры

&НаКлиенте
Процедура ЗакончитьРедактирование(Команда)
	ЗакончитьРедактированиеСервер();
	Элементы.ГруппаРедактированияОписания.ТекущаяСтраница = Элементы.ГруппаПросмотр;
КонецПроцедуры

&НаКлиенте
Процедура КартинкаПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура КартинкаПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;

	ПеретаскиваемоеЗначение = ПараметрыПеретаскивания.Значение;

	Если ТипЗнч(ПеретаскиваемоеЗначение) = Тип("Массив") Тогда
		Если ПеретаскиваемоеЗначение.Количество() > 0 Тогда
			ПеретаскиваемаяКартинка = ПеретаскиваемоеЗначение[0];
		Иначе
			Возврат;
		КонецЕсли;
	Иначе
		ПеретаскиваемаяКартинка = ПеретаскиваемоеЗначение;
	КонецЕсли;

	Если ТипЗнч(ПеретаскиваемаяКартинка) = Тип("СсылкаНаФайл") Тогда
		Расширение = ВРег(ПеретаскиваемаяКартинка.Расширение);
		Если Не (Расширение = ".PNG" Или Расширение = ".JPG" Или Расширение = ".JPEG" Или Расширение = ".GIF"
			Или Расширение = ".BMP") Тогда
			ПоказатьПредупреждение( , НСтр("ru = 'Пожалуйста, перетащите картинку'", "ru"));
			Возврат;
		КонецЕсли;

		Если ПеретаскиваемаяКартинка.Размер() > 1024 * 1024 * 5 Тогда
			ПоказатьПредупреждение( , (НСтр("ru = 'Превышен максимальный размер (5МБ) картинки'", "ru")));
			Возврат;
		КонецЕсли;
	Иначе
		ПоказатьПредупреждение( , НСтр("ru = 'Пожалуйста, перетащите файл'", "ru"));
		Возврат;
	КонецЕсли;

	Если Объект.Ссылка.Пустая() Тогда
		ПоказатьПредупреждение( , НСтр("ru = 'Данные не записаны'", "ru"));
		Возврат;
	Иначе
		ДопПараметры = Новый Структура("Владелец", Объект.Ссылка);
		ОпПослеПомещенияФайла = Новый ОписаниеОповещения("ПослеПомещенияФайла", ЭтотОбъект, ДопПараметры);
		НачатьПомещениеФайлаНаСервер(ОпПослеПомещенияФайла, , , , ПеретаскиваемаяКартинка, УникальныйИдентификатор);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПослеПомещенияФайла(ОписаниеПомещенногоФайла, ДопПараметры) Экспорт

	ПослеПомещенияФайлаНаСервере(ОписаниеПомещенногоФайла.Адрес, ОписаниеПомещенногоФайла.СсылкаНаФайл.Имя,
		ДопПараметры);

КонецПроцедуры

&НаСервере
Процедура ПослеПомещенияФайлаНаСервере(Адрес, ВыбранноеИмяФайла, ДопПараметры)

	ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
	ХранимыйФайл.Владелец = ДопПараметры.Владелец;
	ХранимыйФайл.Наименование = ВыбранноеИмяФайла;
	ХранимыйФайл.ИмяФайла = ВыбранноеИмяФайла;
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(Адрес);
	ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных);
	ХранимыйФайл.Записать();
	Объект.ФайлКартинки = ХранимыйФайл.Ссылка;
	АдресКартинки = ПолучитьНавигационнуюСсылку(ХранимыйФайл.Ссылка, "ДанныеФайла");
	Модифицированность = Истина;

КонецПроцедуры