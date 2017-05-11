*** Settings ***
# Library  String
Library  Selenium2Library
Library  tabua_service.py
# Library  DebugLibrary
# Library  Collections
# Library  BuiltIn

*** Variables ***
${HOME_PAGE}                                           http://staging_sale.tab.com.ua/
${AUCTION_PAGE}                                        http://staging_sale.tab.com.ua/my_auctions

# Auction creation locators
${locator.title}                     id=prozorro_auction_title_ua                         # Lot number (name) according to DGF
${locator.description}               id=prozorro_auction_description_ua                   # Lot is going to be present on Auction
${locator.dgfid}                     id=prozorro_auction_dgf_id                           # dfgID field
${locator.value.amount}              id=prozorro_auction_value_attributes_amount          # Start Lot price
${locator.minimalStep.amount}        id=prozorro_auction_minimal_step_attributes_amount   # Minimal price step-up
${locator.guaranteeamount}           id=prozorro_auction_guarantee_attributes_amount      # Amount of Bank guarantee

${locator.delivery_zip}              id=prozorro_auction_items_attributes_0_postal_code
#${locator.delivery_region}           xpath=//input[@name="region"]
${locator.delivery_town}             id=prozorro_auction_items_attributes_0_locality
${locator.delivery_address}          id=prozorro_auction_items_attributes_0_street_address
#${locator.delivery_save}             xpath=//button[@ng-click="save()"]


*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser
  ...      ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ...      ${USERS.users['${ARGUMENTS[0]}'].browser}
  ...      alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Newtend_Viewer'   Login    ${ARGUMENTS[0]}


Login
  [Arguments]  @{ARGUMENTS}
#  Logs in as Auction owner, who can create Fin auctions
  Wait Until Page Contains Element   id=user_password   20
  Input Text   id=user_email   ${USERS.users['${ARGUMENTS[0]}'].login}
  Input Text   id=user_password   ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Element   xpath=//input[@type="submit"]
  Sleep     2
  Go To  ${HOME_PAGE}
  Wait Until Page Contains Element   xpath=//span[@class="button menu_btn is_logged"]   20
  Sleep     2
  Log To Console   Success logging in as Some one - ${ARGUMENTS[0]}


Оновити сторінку з тендером
	[Arguments]  ${user_name}  ${tender_id}
	Switch Browser	${user_name}
	Reload Page
	Sleep	3s


Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=   update_test_data   ${role_name}   ${tender_data}
  [Return]   ${tender_data}


Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
# Initialisation. Getting values from Dictionary
  Log To Console    Start creating procedure

  ${title}=         Get From Dictionary   ${ARGUMENTS[1].data}               title
  ${description}=   Get From Dictionary   ${ARGUMENTS[1].data}               description
  ${dgfID}=         Get From Dictionary   ${ARGUMENTS[1].data}               dgfID
  ${budget}=        Get From Dictionary   ${ARGUMENTS[1].data.value}         amount
  ${guarantee}=     Get From Dictionary   ${ARGUMENTS[1].data.guarantee}     amount
  ${step_rate}=     Get From Dictionary   ${ARGUMENTS[1].data.minimalStep}   amount
  ${dgfDecisionID}=     Get From Dictionary   ${ARGUMENTS[1].data}        dgfDecisionID
  ${dgfDecisionDate}=   Get From Dictionary   ${ARGUMENTS[1].data}        dgfDecisionDate
  ${tenderAttempts}=    Get From Dictionary   ${ARGUMENTS[1].data}        tenderAttempts

# Date of auction start
  ${start_date}=    Get From Dictionary   ${ARGUMENTS[1].data.auctionPeriod}    startDate

#  Wait Until Page Contains Element   xpath=//a[contains(text(), "Мої аукціони")]   20
#  Click Link                         xpath=//a[contains(text(), "Мої аукціони")]

  Go To  ${AUCTION_PAGE}
  Wait Until Page Contains Element   xpath=//a[contains(text(), "Створити новий аукціон")]   20
  Click Link                         xpath=//a[contains(text(), "Створити новий аукціон")]

# Selecting DGF Financial asset or DGF Other assets
  Wait Until Page Contains Element   xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_financial_assets"]   20
  Run Keyword If  '${mode}' == 'dgfFinancialAssets'  Click Element   xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_financial_assets"]
  Run Keyword If  '${mode}' == 'dgfOtherAssets'      Click Element   xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_other_assets"]

  Log To Console    Selecting Some procedure ${mode}

# Input fields tender
  Input Text   ${locator.title}              ${title}
  Input Text   ${locator.description}        ${description}
  Input Text   ${locator.dgfid}              ${dgfID}

# New fields add
  Input Text   xpath=//input[@id="prozorro_auction_dgf_decision_id"]    ${dgfDecisionID}
  Input Text   xpath=//input[@id="prozorro_auction_dgf_decision_date"]  ${dgfDecisionDate}
  ${tender_attempts}=   Convert To String   ${tenderAttempts}
  Log To Console    attempts - '${tender_attempts}'
  Select From List By Value   xpath=//select[@id="prozorro_auction_tender_attempts"]    ${tender_attempts}

  ${budget_string}      Convert To String    ${budget}
  Input Text   ${locator.value.amount}       ${budget_string}
  Click Element    xpath=//label[@for="prozorro_auction_value_attributes_vat_included"]
  ${step_rate_string}   Convert To String     ${step_rate}
  Input Text   ${locator.minimalStep.amount}  ${step_rate_string}
  ${guarantee_string}   Convert To String     ${guarantee}
  Input Text    ${locator.guaranteeamount}    ${guarantee_string}

#  Items block info
# === Loop Try to select items info ===
  ${item_number}=   substract             ${NUMBER_OF_ITEMS}    1
  ${item_number}=   Convert To Integer    ${item_number}
  log to console    number of items - 1 = '${item_number}'
  : FOR   ${INDEX}  IN RANGE    0    ${NUMBER_OF_ITEMS}
  \   ${items}=         Get From Dictionary   ${ARGUMENTS[1].data}            items
  \   ${item[x]}=                              Get From List               ${items}                 ${INDEX}
  \   ${item_description}=                  Get From Dictionary         ${item[x]}     description
  \   Log to Console    item-0-description '${INDEX}' - '${item_description}'
  \   ${item_quantity}=                     Get From Dictionary         ${item[x]}     quantity
  \   ${unit}=                              Get From Dictionary         ${item[x]}     unit
  \   ${unit_code}=                         Get From Dictionary         ${unit}        code
  \   Log to console      unit code - ${unit_code}
  \   ${unit_name}=                         Get From Dictionary         ${unit}        name
  \   ${classification}=                    Get From Dictionary         ${item[x]}     classification
  \   ${classification_scheme}=             Get From Dictionary         ${classification}    scheme
  \   ${classification_description}=        Get From Dictionary         ${classification}    description
  \   ${classification_id}=                 Get From Dictionary         ${classification}    id
  \   ${deliveryaddress}=                   Get From Dictionary         ${item[x]}           deliveryAddress
  \   ${deliveryaddress_postalcode}=        Get From Dictionary         ${deliveryaddress}   postalCode
  \   ${deliveryaddress_countryname}=       Get From Dictionary         ${deliveryaddress}   countryName
  \   ${deliveryaddress_streetaddress}=     Get From Dictionary         ${deliveryaddress}   streetAddress
  \   ${deliveryaddress_region}=            Get From Dictionary         ${deliveryaddress}   region
  \   ${deliveryaddress_locality}=          Get From Dictionary         ${deliveryaddress}   locality
  \   Log To Console    index - ${INDEX}
# Add Item(s)
  \   Input Text    id=prozorro_auction_items_attributes_0_description_ua     ${item_description}
  \   Input Text    id=prozorro_auction_items_attributes_0_quantity           ${item_quantity}
  \   ${spec_unit_name}=   get_select_unit_name   ${unit_name}
  \   Select From List By Value   xpath=//select[@id="prozorro_auction_items_attributes_0_unit_code"]    ${spec_unit_name}
# Selecting classifier
  \   ${classifier_field}=      Get Webelements     xpath=//span[@class="btn btn_editing"]
  \   Click Element     ${classifier_field[-1]}
  \   Sleep     2
  \   Input Text        id=search_classification    ${classification_id}
  \   ${nonzero_num}=   get_nonzero_num   ${classification_id}
  \   set_clacifier   ${nonzero_num}   ${classification_id}
  \   Click Element     xpath=//span[@class='button btn_adding']
  \   Sleep     2
# Add delivery address
  \   Input Text        ${locator.delivery_zip}      ${deliveryaddress_postalcode}
#  \   Input Text        ${locator.delivery_region}   ${deliveryaddress_region}
  \   Input Text        ${locator.delivery_town}     ${deliveryaddress_locality}
  \   Input Text        ${locator.delivery_address}  ${deliveryaddress_streetaddress}
#  \   Click Element     ${locator.delivery_save}
#  \   Sleep     3
#  \   ${new_item_cross}=    Get Webelements     xpath=//a[@ng-click="addField()"]
#  \   Run Keyword If   '${INDEX}' < '${item_number}'   Click Element    ${new_item_cross[-1]}






  Log To Console    attempts - lallalalallalal


  Sleep	5

set_clacifier
  [Arguments]        ${nonzero_num}   ${classification_id}
  :FOR   ${INDEX_N}  IN RANGE    2    ${nonzero_num}
  \   ${first_code_symbols}=   get_first_symbols   ${classification_id}   ${INDEX_N}
  \   Click Element     xpath=//label[starts-with(@for, '${first_code_symbols}')]
  \   Sleep     2