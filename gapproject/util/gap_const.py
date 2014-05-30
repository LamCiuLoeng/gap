# coding: utf-8

#  update ##### 2 = complete(AE update) 不用了 ------
# 0: cancel,
# 1: new/customer,
# 2: reserve fail，
# 3: partial reserve success,
# 4: reserve success，
# 5: shipped part,
# 6: shipped complete

__all__ = ['CANCEL', 'NEW', 'RESERVED_FAIL', 'PARTIAL_RESERVED_SUCCESS', 'ALL_RESERVED_SUCCESS',
    'SHIPPED_PART', 'SHIPPED_COMPLETE', 'orderStatus']

CANCEL = 0
NEW = 1
RESERVED_FAIL = 2
PARTIAL_RESERVED_SUCCESS = 3
ALL_RESERVED_SUCCESS = 4
SHIPPED_PART = 5
SHIPPED_COMPLETE = 6

orderStatus = {
    CANCEL: 'Cancel',
    NEW: 'New',
    RESERVED_FAIL: 'Reserve Fail',
    PARTIAL_RESERVED_SUCCESS: 'Partial Reserve Success',
    ALL_RESERVED_SUCCESS: 'All Reserve Success',
    SHIPPED_PART: 'Shipped Part',
    SHIPPED_COMPLETE: 'Shipped Complete'
}
