# -*- coding: utf-8 -*-

# from datetime import datetime
# from pytz import timezone
# from iso8601 import parse_date
# from op_robot_tests.tests_files.service_keywords import get_now
# from calendar import monthrange
# import urllib



def update_test_data(role_name, tender_data):
    if role_name == 'tender_owner':
        tender_data['data']['procuringEntity']['name'] = u"VVV"
    return tender_data

def substract(dividend, divisor):
    return int(dividend) - int(divisor)

def get_select_unit_name(standard_unit_name):
    unit_name_dictionary = {
        u'послуга': 'E48',
        u'ящик': 'BX',
        u'блок': 'D64',
        u'Гігакалорія': 'GRM',
        # u'роботи': '',
        u'рейс': 'E54',
        u'штуки': 'H87',
        u'гектар': 'HAR',
        u'кілограми': 'KGM',
        u'кілометри': 'KMT',
        # u'комплект': '',
    }

    return unit_name_dictionary[standard_unit_name]

def get_nonzero_num(code_str):
    code_str = code_str.split('-')[0]
    while code_str[-1] == '0':
        code_str = code_str[:-1]

    return len(code_str) + 1


def get_first_symbols(code_str, num):
    return 'cav_' + code_str[:int(num)]