*** Settings ***
Library            op_robot_tests.tests_files.service_keywords
Library            Collections
Resource           keywords.robot
Resource           resource.robot


*** Keywords ***
Можливість оголосити тендер
  ${NUMBER_OF_ITEMS}=  Convert To Integer  ${NUMBER_OF_ITEMS}
  ${tender_parameters}=  Create Dictionary
  ...      mode=${MODE}
  ...      number_of_items=${NUMBER_OF_ITEMS}
  ...      tender_meat=${${TENDER_MEAT}}
  ...      item_meat=${${ITEM_MEAT}}
  ...      api_host_url=${API_HOST_URL}
  ${DIALOGUE_TYPE}=  Get Variable Value  ${DIALOGUE_TYPE}
  Run keyword if  '${DIALOGUE_TYPE}' != '${None}'  Set to dictionary  ${tender_parameters}  dialogue_type=${DIALOGUE_TYPE}
  ${tender_data}=  Підготувати дані для створення тендера  ${tender_parameters}
  ${adapted_data}=  Адаптувати дані для оголошення тендера  ${tender_data}
  ${TENDER_UAID}=  Run As  ${tender_owner}  Створити тендер  ${adapted_data}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  initial_data=${adapted_data}
  Set To Dictionary  ${TENDER}  TENDER_UAID=${TENDER_UAID}


Можливість знайти тендер по ідентифікатору для усіх користувачів
  :FOR  ${username}  IN  ${tender_owner}  ${provider}  ${provider1}  ${viewer}
  \  Можливість знайти тендер по ідентифікатору для користувача ${username}


Можливість знайти тендер по ідентифікатору для користувача ${username}
  Дочекатись синхронізації з майданчиком  ${username}
  Run as  ${username}  Пошук тендера по ідентифікатору  ${TENDER['TENDER_UAID']}


Можливість змінити поле ${field_name} тендера на ${field_value}
  Run As  ${tender_owner}  Внести зміни в тендер  ${TENDER['TENDER_UAID']}  ${field_name}  ${field_value}


Можливість додати документацію до тендера
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Run As  ${tender_owner}  Завантажити документ  ${file_path}  ${TENDER['TENDER_UAID']}
  ${doc_id}=  get_id_from_doc_name  ${file_name}
  ${tender_document}=  Create Dictionary  doc_name=${file_name}  doc_id=${doc_id}  doc_content=${file_content}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  tender_document=${tender_document}
  Remove File  ${file_path}


Можливість додати ілюстрацію до тендера
  ${image_path}=  create_fake_image
  Run As  ${tender_owner}  Завантажити ілюстрацію  ${TENDER['TENDER_UAID']}  ${image_path}


Можливість додати Virtual Data Room до тендера
  ${vdr_url}=  create_fake_url
  Run As  ${tender_owner}  Додати Virtual Data Room  ${TENDER['TENDER_UAID']}  ${vdr_url}


Можливість додати публічний паспорт активу до тендера
  ${certificate_url}=  create_fake_url
  Run As  ${tender_owner}  Додати публічний паспорт активу  ${TENDER['TENDER_UAID']}  ${certificate_url}


Можливість додати офлайн документ
  ${accessDetails}=  create_fake_sentence
  Run As  ${tender_owner}  Додати офлайн документ  ${TENDER['TENDER_UAID']}  ${accessDetails}


Можливість завантажити документ до тендера з типом ${doc_type}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Run As  ${tender_owner}  Завантажити документ в тендер з типом  ${TENDER['TENDER_UAID']}  ${file_path}  ${doc_type}


Можливість додати предмет закупівлі в тендер
  ${item}=  Підготувати дані для створення предмету закупівлі  ${USERS.users['${tender_owner}'].initial_data.data['items'][0]['classification']['id']}
  Run As  ${tender_owner}  Додати предмет закупівлі  ${TENDER['TENDER_UAID']}  ${item}
  ${item_id}=  get_id_from_object  ${item}
  ${item_data}=  Create Dictionary  item=${item}  item_id=${item_id}
  ${item_data}=  munch_dict  arg=${item_data}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  item_data=${item_data}


Можливість видалити предмет закупівлі з тендера
  Run As  ${tender_owner}  Видалити предмет закупівлі  ${TENDER['TENDER_UAID']}  ${USERS.users['${tender_owner}'].item_data.item_id}


Неможливість додати предмет закупівлі в тендер
  ${len_of_items_before_patch}=  Run As  ${tender_owner}  Отримати кількість предметів в тендері  ${TENDER['TENDER_UAID']}
  ${item}=  Підготувати дані для створення предмету закупівлі  ${USERS.users['${tender_owner}'].initial_data.data['items'][0]['classification']['id']}
  Run As  ${tender_owner}  Додати предмет закупівлі  ${TENDER['TENDER_UAID']}  ${item}
  ${len_of_items_after_patch}=  Run As  ${tender_owner}  Отримати кількість предметів в тендері  ${TENDER['TENDER_UAID']}
  Порівняти об'єкти  ${len_of_items_before_patch}  ${len_of_items_after_patch}


Неможливість видалити предмет закупівлі з тендера
  ${len_of_items_before_patch}=  Run As  ${tender_owner}  Отримати кількість предметів в тендері  ${TENDER['TENDER_UAID']}
  ${item_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].initial_data.data['items'][0]}
  Run As  ${tender_owner}  Видалити предмет закупівлі  ${TENDER['TENDER_UAID']}  ${item_id}
  ${len_of_items_after_patch}=  Run As  ${tender_owner}  Отримати кількість предметів в тендері  ${TENDER['TENDER_UAID']}
  Порівняти об'єкти  ${len_of_items_before_patch}  ${len_of_items_after_patch}


Звірити відображення поля ${field} документа ${doc_id} із ${left} для користувача ${username}
  ${right}=  Run As  ${username}  Отримати інформацію із документа  ${TENDER['TENDER_UAID']}  ${doc_id}  ${field}
  Порівняти об'єкти  ${left}  ${right}


Звірити відображення поля ${field} тендера для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Звірити відображення поля ${field} тендера для користувача ${username}


Звірити відображення поля ${field} тендера із ${data} для користувача ${username}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}  ${data}  ${field}


Звірити відображення поля ${field} тендера для користувача ${username}
  Log To Console    ira1 username - ${username}
  Log To Console    ira2 field - ${field}

  Звірити поле тендера  ${username}  ${TENDER['TENDER_UAID']}  ${USERS.users['${tender_owner}'].initial_data}  ${field}


Звірити відображення вмісту документа ${doc_id} із ${left} для користувача ${username}
  ${file_name}=  Run as  ${username}  Отримати документ  ${TENDER['TENDER_UAID']}  ${doc_id}
  ${right}=  Get File  ${OUTPUT_DIR}${/}${file_name}
  Порівняти об'єкти  ${left}  ${right}


Звірити відображення дати ${date} тендера для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Звірити відображення дати ${date} тендера для користувача ${username}


Звірити відображення дати ${date} тендера для користувача ${username}
  Звірити дату тендера  ${username}  ${TENDER['TENDER_UAID']}  ${USERS.users['${tender_owner}'].initial_data}  ${date}


Звірити відображення поля ${field} у новоствореному предметі для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Звірити відображення поля ${field} у новоствореному предметі для користувача ${username}


Звірити відображення поля ${field} у новоствореному предметі для користувача ${username}
  Дочекатись синхронізації з майданчиком  ${username}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${tender_owner}'].item_data.item.${field}}  ${field}
  ...      object_id=${USERS.users['${tender_owner}'].item_data.item_id}


Звірити відображення поля ${field} усіх предметів для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Звірити відображення поля ${field} усіх предметів для користувача ${username}


Звірити відображення поля ${field} усіх предметів для користувача ${username}
  :FOR  ${item_index}  IN RANGE  ${NUMBER_OF_ITEMS}
  \  Звірити відображення поля ${field} ${item_index} предмету для користувача ${username}


Звірити відображення поля ${field} ${item_index} предмету для користувача ${username}
  ${item_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].initial_data.data['items'][${item_index}]}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}  ${USERS.users['${tender_owner}'].initial_data.data['items'][${item_index}].${field}}  ${field}  ${item_id}


Звірити відображення дати ${field} усіх предметів для користувача ${username}
  :FOR  ${item_index}  IN RANGE  ${NUMBER_OF_ITEMS}
  \  Звірити відображення дати ${field} ${item_index} предмету для користувача ${username}


Звірити відображення дати ${date} ${item_index} предмету для користувача ${username}
  ${item_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].initial_data.data['items'][${item_index}]}
  Звірити дату тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}  ${USERS.users['${tender_owner}'].initial_data.data['items'][${item_index}].${date}}  ${date}  ${item_id}


Звірити відображення координат усіх предметів для користувача ${username}
  :FOR  ${item_index}  IN RANGE  ${NUMBER_OF_ITEMS}
  \  Звірити відображення координат ${item_index} предмету для користувача ${username}


Звірити відображення координат ${item_index} предмету для користувача ${username}
  ${item_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].initial_data.data['items'][${item_index}]}
  Звірити координати доставки тендера  ${viewer}  ${TENDER['TENDER_UAID']}  ${USERS.users['${tender_owner}'].initial_data}  ${item_id}


Звірити належність усіх предметів до різних груп для користувача ${username}
  :FOR  ${item_index}  IN RANGE  ${NUMBER_OF_ITEMS}
  \  @{items}=  Отримати дані із тендера  ${username}  ${TENDER['TENDER_UAID']}  items
  ${len_of_items}=  Get Length  ${items}
  ${comparision}=  compare_CAV_groups  ${len_of_items}  @{items}
  Should Be True  ${comparision}


Отримати дані із поля ${field} тендера для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${provider}  ${provider1}  ${tender_owner}
  \  Отримати дані із поля ${field} тендера для користувача ${username}


Отримати дані із поля ${field} тендера для користувача ${username}
  Отримати дані із тендера  ${username}  ${TENDER['TENDER_UAID']}  ${field}

##############################################################################################
#             FEATURES
##############################################################################################

Можливість додати неціновий показник на тендер
  ${feature}=  Підготувати дані для створення нецінового показника
  Set To Dictionary  ${feature}  featureOf=tenderer
  Run As  ${tender_owner}  Додати неціновий показник на тендер  ${TENDER['TENDER_UAID']}  ${feature}
  ${feature_id}=  get_id_from_object  ${feature}
  ${feature_data}=  Create Dictionary  feature=${feature}  feature_id=${feature_id}
  ${feature_data}=  munch_dict  arg=${feature_data}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  feature_data=${feature_data}


Можливість додати неціновий показник на ${item_index} предмет
  ${feature}=  Підготувати дані для створення нецінового показника
  Set To Dictionary  ${feature}  featureOf=item
  ${item_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].tender_data.data['items'][${item_index}]}
  Run As  ${tender_owner}  Додати неціновий показник на предмет  ${TENDER['TENDER_UAID']}  ${feature}  ${item_id}
  ${feature_id}=  get_id_from_object  ${feature}
  ${feature_data}=  Create Dictionary  feature=${feature}  feature_id=${feature_id}
  ${feature_data}=  munch_dict  arg=${feature_data}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  feature_data=${feature_data}


Звірити відображення поля ${field} у новоствореному неціновому показнику для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Звірити відображення поля ${field} у новоствореному неціновому показнику для користувача ${username}


Звірити відображення поля ${field} у новоствореному неціновому показнику для користувача ${username}
  Дочекатись синхронізації з майданчиком  ${username}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${tender_owner}'].feature_data.feature.${field}}  ${field}
  ...      object_id=${USERS.users['${tender_owner}'].feature_data.feature_id}


Звірити відображення поля ${field} усіх нецінових показників для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Звірити відображення поля ${field} усіх нецінових показників для користувача ${username}


Звірити відображення поля ${field} усіх нецінових показників для користувача ${username}
  ${number_of_features}=  Get Length  ${USERS.users['${tender_owner}'].initial_data.data.features}
  :FOR  ${feature_index}  IN RANGE  ${number_of_features}
  \  Звірити відображення поля ${field} ${feature_index} нецінового показника для користувача ${username}


Звірити відображення поля ${field} ${feature_index} нецінового показника для користувача ${username}
  Дочекатись синхронізації з майданчиком  ${username}
  ${feature_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].initial_data.data.features[${feature_index}]}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${tender_owner}'].initial_data.data.features[${feature_index}].${field}}  ${field}
  ...      object_id=${feature_id}


Можливість видалити ${feature_index} неціновий показник
  ${feature_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].tender_data.data['features'][${feature_index}]}
  Run As  ${tender_owner}  Видалити неціновий показник  ${TENDER['TENDER_UAID']}  ${feature_id}
  ${feature_index}=  get_object_index_by_id  ${USERS.users['${tender_owner}'].tender_data.data['features']}  ${feature_id}
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Remove From List  ${USERS.users['${username}'].tender_data.data['features']}  ${feature_index}

##############################################################################################
#             QUESTIONS
##############################################################################################

Можливість задати запитання на тендер користувачем ${username}
  ${question}=  Підготувати дані для запитання
  ${question_resp}=  Run As  ${username}  Задати запитання на тендер  ${TENDER['TENDER_UAID']}  ${question}
  ${now}=  Get Current TZdate
  ${question.data.date}=  Set variable  ${now}
  ${question_id}=  get_id_from_object  ${question.data}
  ${question_data}=  Create Dictionary  question=${question}  question_resp=${question_resp}  question_id=${question_id}
  ${question_data}=  munch_dict  arg=${question_data}
  Set To Dictionary  ${USERS.users['${username}']}  tender_question_data=${question_data}


Можливість задати запитання на ${item_index} предмет користувачем ${username}
  ${item_id}=  get_id_from_object  ${USERS.users['${tender_owner}'].tender_data.data['items'][${item_index}]}
  ${question}=  Підготувати дані для запитання
  ${question_resp}=  Run As  ${username}  Задати запитання на предмет  ${TENDER['TENDER_UAID']}  ${item_id}  ${question}
  ${now}=  Get Current TZdate
  ${question.data.date}=  Set variable  ${now}
  ${question_id}=  get_id_from_object  ${question.data}
  ${question_data}=  Create Dictionary  question=${question}  question_resp=${question_resp}  question_id=${question_id}
  ${question_data}=  munch_dict  arg=${question_data}
  Set To Dictionary  ${USERS.users['${username}']}  items_${item_index}_question_data=${question_data}


Можливість відповісти на запитання на тендер
  ${answer}=  Підготувати дані для відповіді на запитання
  Run As  ${tender_owner}
  ...      Відповісти на запитання  ${TENDER['TENDER_UAID']}
  ...      ${answer}
  ...      ${USERS.users['${provider}'].tender_question_data.question_id}
  Set To Dictionary  ${USERS.users['${provider}'].tender_question_data.question.data}  answer=${answer.data.answer}


Можливість відповісти на запитання на ${item_index} предмет
  ${answer}=  Підготувати дані для відповіді на запитання
  Run As  ${tender_owner}
  ...      Відповісти на запитання  ${TENDER['TENDER_UAID']}
  ...      ${answer}
  ...      ${USERS.users['${provider}'].items_${item_index}_question_data.question_id}
  Set To Dictionary  ${USERS.users['${provider}'].items_${item_index}_question_data.question.data}  answer=${answer.data.answer}


Звірити відображення поля ${field} запитання на тендер для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Дочекатись синхронізації з майданчиком  ${username}
  \  Звірити відображення поля ${field} запитання на тендер для користувача ${username}


Звірити відображення поля ${field} запитання на тендер для користувача ${username}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}  ${USERS.users['${provider}'].tender_question_data.question.data.${field}}  ${field}  ${USERS.users['${provider}'].tender_question_data.question_id}


Звірити відображення поля ${field} запитання на ${item_index} предмет для усіх користувачів
  :FOR  ${username}  IN  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  \  Дочекатись синхронізації з майданчиком  ${username}
  \  Звірити відображення поля ${field} запитання на ${item_index} предмет для користувача ${username}


Звірити відображення поля ${field} запитання на ${item_index} предмет для користувача ${username}
  Звірити поле тендера із значенням  ${username}  ${TENDER['TENDER_UAID']}  ${USERS.users['${provider}'].items_${item_index}_question_data.question.data.${field}}  ${field}  ${USERS.users['${provider}'].items_${item_index}_question_data.question_id}

##############################################################################################
#             COMPLAINTS
##############################################################################################


Можливість створити чернетку вимоги про виправлення умов закупівлі
  ${claim}=  Підготувати дані для подання вимоги
  ${complaintID}=  Run As  ${provider}
  ...      Створити чернетку вимоги про виправлення умов закупівлі
  ...      ${TENDER['TENDER_UAID']}
  ...      ${claim}
  ${claim_data}=  Create Dictionary  claim=${claim}  complaintID=${complaintID}
  ${claim_data}=  munch_dict  arg=${claim_data}
  Set To Dictionary  ${USERS.users['${provider}']}  claim_data  ${claim_data}


Можливість створити чернетку вимоги про виправлення визначення ${award_index} переможця
  ${claim}=  Підготувати дані для подання вимоги
  ${complaintID}=  Run As  ${provider}
  ...      Створити чернетку вимоги про виправлення визначення переможця
  ...      ${TENDER['TENDER_UAID']}
  ...      ${claim}
  ...      ${award_index}
  ${claim_data}=  Create Dictionary  claim=${claim}  complaintID=${complaintID}
  ${claim_data}=  munch_dict  arg=${claim_data}
  Set To Dictionary  ${USERS.users['${provider}']}  claim_data  ${claim_data}


Можливість створити вимогу про виправлення умов закупівлі із документацією
  ${claim}=  Підготувати дані для подання вимоги
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${complaintID}=  Run As  ${provider}
  ...      Створити вимогу про виправлення умов закупівлі
  ...      ${TENDER['TENDER_UAID']}
  ...      ${claim}
  ...      ${file_path}
  ${doc_id}=  get_id_from_doc_name  ${file_name}
  ${claim_data}=  Create Dictionary  claim=${claim}  complaintID=${complaintID}  doc_name=${file_name}  doc_id=${doc_id}  doc_content=${file_content}
  ${claim_data}=  munch_dict  arg=${claim_data}
  Set To Dictionary  ${USERS.users['${provider}']}  claim_data  ${claim_data}
  Remove File  ${file_path}


Можливість створити вимогу про виправлення визначення ${award_index} переможця із документацією
  ${claim}=  Підготувати дані для подання вимоги
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${complaintID}=  Run As  ${provider}
  ...      Створити вимогу про виправлення визначення переможця
  ...      ${TENDER['TENDER_UAID']}
  ...      ${claim}
  ...      ${award_index}
  ...      ${file_path}
  ${doc_id}=  get_id_from_doc_name  ${file_name}
  ${claim_data}=  Create Dictionary  claim=${claim}  complaintID=${complaintID}  doc_name=${file_name}  doc_id=${doc_id}  doc_content=${file_content}
  ${claim_data}=  munch_dict  arg=${claim_data}
  Set To Dictionary  ${USERS.users['${provider}']}  claim_data  ${claim_data}
  Remove File  ${file_path}


Можливість скасувати вимогу про виправлення умов закупівлі
  ${cancellation_reason}=  create_fake_sentence
  ${data}=  Create Dictionary  status=cancelled  cancellationReason=${cancellation_reason}
  ${cancellation_data}=  Create Dictionary  data=${data}
  ${cancellation_data}=  munch_dict  arg=${cancellation_data}
  Run As  ${provider}
  ...      Скасувати вимогу про виправлення умов закупівлі
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${cancellation_data}
  Set To Dictionary  ${USERS.users['${provider}'].claim_data}  cancellation  ${cancellation_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      cancelled


Можливість скасувати вимогу про виправлення визначення ${award_index} переможця
  ${cancellation_reason}=  create_fake_sentence
  ${status}=  Set variable if  'open' in '${MODE}'  stopping  cancelled
  ${data}=  Create Dictionary  status=${status}  cancellationReason=${cancellation_reason}
  ${cancellation_data}=  Create Dictionary  data=${data}
  ${cancellation_data}=  munch_dict  arg=${cancellation_data}
  Run As  ${provider}
  ...      Скасувати вимогу про виправлення визначення переможця
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${cancellation_data}
  ...      ${award_index}
  Set To Dictionary  ${USERS.users['${provider}'].claim_data}  cancellation  ${cancellation_data}
  ${status}=  Set variable if  'open' in '${MODE}'  stopping  cancelled
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${status}
  ...      ${award_index}


Можливість перетворити вимогу про виправлення умов закупівлі в скаргу
  ${data}=  Create Dictionary  status=pending  satisfied=${False}
  ${escalation_data}=  Create Dictionary  data=${data}
  ${escalation_data}=  munch_dict  arg=${escalation_data}
  Run As  ${provider}
  ...      Перетворити вимогу про виправлення умов закупівлі в скаргу
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${escalation_data}
  Set To Dictionary  ${USERS.users['${provider}'].claim_data}  escalation  ${escalation_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      pending


Можливість перетворити вимогу про виправлення визначення ${award_index} переможця в скаргу
  ${data}=  Create Dictionary  status=pending  satisfied=${False}
  ${escalation_data}=  Create Dictionary  data=${data}
  ${escalation_data}=  munch_dict  arg=${escalation_data}
  Run As  ${provider}
  ...      Перетворити вимогу про виправлення визначення переможця в скаргу
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${escalation_data}
  ...      ${award_index}
  Set To Dictionary  ${USERS.users['${provider}'].claim_data}  escalation  ${escalation_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      pending
  ...      ${award_index}


Звірити відображення поля ${field} вимоги із ${data} для користувача ${username}
  Звірити поле скарги із значенням
  ...      ${username}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${data}
  ...      ${field}
  ...      ${USERS.users['${provider}'].claim_data['complaintID']}


Звірити відображення поля ${field} вимоги про виправлення визначення ${award_index} переможця із ${data} для користувача ${username}
  Звірити поле скарги із значенням
  ...      ${username}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${data}
  ...      ${field}
  ...      ${USERS.users['${provider}'].claim_data['complaintID']}
  ...      ${award_index}


Можливість відповісти на вимогу про виправлення умов закупівлі
  ${answer_data}=  test_claim_answer_data
  Log  ${answer_data}
  Run As  ${tender_owner}
  ...      Відповісти на вимогу про виправлення умов закупівлі
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${answer_data}
  ${claim_data}=  Create Dictionary  claim_answer=${answer_data}
  ${claim_data}=  munch_dict  arg=${claim_data}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  claim_data  ${claim_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      answered


Можливість відповісти на вимогу про виправлення визначення ${award_index} переможця
  ${answer_data}=  test_claim_answer_data
  Log  ${answer_data}
  Run As  ${tender_owner}
  ...      Відповісти на вимогу про виправлення визначення переможця
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${answer_data}
  ...      ${award_index}
  ${claim_data}=  Create Dictionary  claim_answer=${answer_data}
  ${claim_data}=  munch_dict  arg=${claim_data}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  claim_data  ${claim_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      answered
  ...      ${award_index}


Можливість підтвердити задоволення вимоги про виправлення умов закупівлі
  ${data}=  Create Dictionary  status=resolved  satisfied=${True}
  ${confirmation_data}=  Create Dictionary  data=${data}
  ${confirmation_data}=  munch_dict  arg=${confirmation_data}
  Run As  ${provider}
  ...      Підтвердити вирішення вимоги про виправлення умов закупівлі
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${confirmation_data}
  Set To Dictionary  ${USERS.users['${provider}']['claim_data']}  claim_answer_confirm  ${confirmation_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      resolved


Можливість підтвердити задоволення вимоги про виправлення визначення ${award_index} переможця
  ${data}=  Create Dictionary  status=resolved  satisfied=${True}
  ${confirmation_data}=  Create Dictionary  data=${data}
  ${confirmation_data}=  munch_dict  arg=${confirmation_data}
  Run As  ${provider}
  ...      Підтвердити вирішення вимоги про виправлення визначення переможця
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${confirmation_data}
  ...      ${award_index}
  Set To Dictionary  ${USERS.users['${provider}']['claim_data']}  claim_answer_confirm  ${confirmation_data}
  Wait until keyword succeeds
  ...      5 min 15 sec
  ...      15 sec
  ...      Звірити статус вимоги/скарги
  ...      ${provider}
  ...      ${TENDER['TENDER_UAID']}
  ...      ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      resolved
  ...      ${award_index}


Звірити відображення поля ${field} документа ${doc_id} до скарги ${complaintID} з ${left} для користувача ${username}
  ${right}=  Run As  ${username}  Отримати інформацію із документа до скарги  ${TENDER['TENDER_UAID']}  ${complaintID}  ${doc_id}  ${field}
  Порівняти об'єкти  ${left}  ${right}


Звірити відображення вмісту документа ${doc_id} до скарги ${complaintID} з ${left} для користувача ${username}
  ${file_name}=  Run as  ${username}  Отримати документ до скарги  ${TENDER['TENDER_UAID']}  ${complaintID}  ${doc_id}
  ${right}=  Get File  ${OUTPUT_DIR}${/}${file_name}
  Порівняти об'єкти  ${left}  ${right}

##############################################################################################
#             BIDDING
##############################################################################################

Можливість подати цінову пропозицію користувачем ${username}
  ${bid}=  Підготувати дані для подання пропозиції  ${username}
  ${bidresponses}=  Create Dictionary  bid=${bid}
  Set To Dictionary  ${USERS.users['${username}']}  bidresponses=${bidresponses}
  ${features}=  Get Variable Value  ${USERS.users['${username}'].tender_data.data.features}  ${None}
  ${features_ids}=  Run Keyword IF  ${features}
  ...     Отримати ідентифікатори об’єктів  ${username}  features
  ...     ELSE  Set Variable  ${None}
  ${resp}=  Run As  ${username}  Подати цінову пропозицію  ${TENDER['TENDER_UAID']}  ${bid}
  Set To Dictionary  ${USERS.users['${username}'].bidresponses}  resp=${resp}
  Run Keyword If  '${MODE}'=='dgfFinancialAssets'
  ...             Можливість завантажити фінансову ліцензію в пропозицію користувачем ${username}


Неможливість подати цінову пропозицію без нецінових показників користувачем ${username}
  ${bid}=  Підготувати дані для подання пропозиції  ${username}
  Remove From Dictionary  ${bid.data}  parameters
  Require Failure  ${username}  Подати цінову пропозицію  ${TENDER['TENDER_UAID']}  ${bid}


Неможливість подати цінову попрозицію без кваліфікації користувачем ${username}
  ${bid}=  Підготувати дані для подання пропозиції  ${username}
  ${bid['data'].qualified} =  Set Variable  ${False}
  Require Failure  ${username}  Подати цінову пропозицію  ${TENDER['TENDER_UAID']}  ${bid}


Можливість збільшити пропозицію до ${percent} відсотків користувачем ${username}
  ${percent}=  Convert To Number  ${percent}
  ${divider}=  Convert To Number  0.01
  ${field}=  Set Variable  value.amount
  ${value}=  Run As  ${username}  Отримати інформацію із пропозиції  ${TENDER['TENDER_UAID']}  ${field}
  ${value}=  mult_and_round  ${value}  ${percent}  ${divider}  precision=${2}
  Run as  ${username}  Змінити цінову пропозицію  ${TENDER['TENDER_UAID']}  ${field}  ${value}


Можливість завантажити документ в пропозицію користувачем ${username}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${bid_doc_upload}=  Run As  ${username}  Завантажити документ в ставку  ${file_path}  ${TENDER['TENDER_UAID']}
  Set To Dictionary  ${USERS.users['${username}'].bidresponses}  bid_doc_upload=${bid_doc_upload}
  Remove File  ${file_path}


Можливість змінити документацію цінової пропозиції користувачем ${username}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${docid}=  Get Variable Value  ${USERS.users['${username}'].bidresponses['bid_doc_upload']['upload_response'].data.id}
  ${bid_doc_modified}=  Run As  ${username}  Змінити документ в ставці  ${TENDER['TENDER_UAID']}  ${file_path}  ${docid}
  Set To Dictionary  ${USERS.users['${username}'].bidresponses}  bid_doc_modified=${bid_doc_modified}
  Remove File  ${file_path}


Можливість завантажити фінансову ліцензію в пропозицію користувачем ${username}
  ${financial_license_path}  ${file_title}  ${file_content}=  create_fake_doc
  Run As  ${username}  Завантажити фінансову ліцензію  ${TENDER['TENDER_UAID']}  ${financial_license_path}
  Remove File  ${financial_license_path}


Можливість завантажити протокол аукціону в пропозицію ${bid_index} користувачем ${username}
  ${auction_protocol_path}  ${file_title}  ${file_content}=  create_fake_doc
  Run As  ${username}  Завантажити протокол аукціону  ${TENDER['TENDER_UAID']}  ${auction_protocol_path}  ${bid_index}
  Remove File  ${auction_protocol_path}

Можливість завантажити протокол аукціону в авард ${award_index} користувачем ${username}
  ${auction_protocol_path}  ${file_title}  ${file_content}=  create_fake_doc
  Run As  ${username}  Завантажити протокол аукціону в авард  ${TENDER['TENDER_UAID']}  ${auction_protocol_path}  ${award_index}
  Remove File  ${auction_protocol_path}

##############################################################################################
#             Cancellations
##############################################################################################

Можливість скасувати цінову пропозицію користувачем ${username}
  Run As  ${username}  Скасувати цінову пропозицію  ${TENDER['TENDER_UAID']}

##############################################################################################
#             Awarding
##############################################################################################

Можливість зареєструвати, додати документацію і підтвердити постачальника до закупівлі
  ${supplier_data}=  Підготувати дані про постачальника  ${tender_owner}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Run as  ${tender_owner}
  ...      Створити постачальника, додати документацію і підтвердити його
  ...      ${TENDER['TENDER_UAID']}
  ...      ${supplier_data}
  ...      ${file_path}
  ${doc_id}=  get_id_from_doc_name  ${file_name}
  Set to dictionary  ${USERS.users['${tender_owner}']}  award_doc_name=${file_name}  award_doc_id=${doc_id}  award_doc_content=${file_content}
  Remove File  ${file_path}


Можливість укласти угоду для закупівлі
  Run as  ${tender_owner}
  ...      Підтвердити підписання контракту
  ...      ${TENDER['TENDER_UAID']}
  ...      ${0}
  Run Keyword And Ignore Error  Remove From Dictionary  ${USERS.users['${viewer}'].tender_data.contracts[0]}  status
