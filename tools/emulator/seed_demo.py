"""Generate fictional data in the loopback-only demo-cashiere emulator."""
import datetime
import json
import os
import pathlib
import subprocess
import urllib.request

root = pathlib.Path(__file__).resolve().parents[2]
password_hash = subprocess.check_output(['dart', 'run', 'tools/emulator/hash_demo.dart'], cwd=root, text=True, shell=os.name == 'nt').strip().splitlines()[-1]
assert password_hash.startswith('$2')
timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

def encode(value):
    if isinstance(value, bool): return {'booleanValue': value}
    if isinstance(value, int): return {'integerValue': str(value)}
    if isinstance(value, float): return {'doubleValue': value}
    if isinstance(value, dict) and '_timestamp' in value: return {'timestampValue': value['_timestamp']}
    return {'stringValue': str(value)}

def put(path, data):
    url = 'http://127.0.0.1:8081/v1/projects/demo-cashiere/databases/(default)/documents/' + path
    request = urllib.request.Request(url, data=json.dumps({'fields': {k: encode(v) for k, v in data.items()}}).encode(), headers={'Content-Type': 'application/json'}, method='PATCH')
    with urllib.request.urlopen(request, timeout=20) as response:
        assert response.status == 200

date = {'_timestamp': timestamp}
put('employees/demo-admin', {'name': 'Demo Admin', 'email': 'demo@example.com', 'passwordHash': password_hash, 'role': 'admin', 'isActive': True, 'createdAt': date})
for ident, name in [('phones', 'Smartphones'), ('tablets', 'Tablets'), ('accessories', 'Accessories')]:
    put('categories/' + ident, {'id': ident, 'name': name, 'isActive': True, 'createdAt': date, 'updatedAt': date})
for index, (name, price, category) in enumerate([('iPhone 15 Pro', 32000, 'phones'), ('Samsung Galaxy S24', 28000, 'phones'), ('iPad Air', 24000, 'tablets'), ('Galaxy Tab S9', 21000, 'tablets'), ('Wireless Charger', 850, 'accessories'), ('USB-C Cable', 250, 'accessories')], 1):
    ident = 'demo-device-' + str(index)
    put('inventory_devices/' + ident, {'id': ident, 'deviceName': name, 'barcode': 'DEMO-' + str(index), 'serialNumber1': 'DEMO-SERIAL-' + str(index), 'serialNumber2': '', 'condition': 'new', 'color': 'Black', 'storage': '256GB', 'receivingPrice': price * .8, 'sellingPrice': price, 'paymentMethod': 'cash', 'supplierName': 'Demo Supplier', 'supplierPhone': '0000000000', 'categoryId': category, 'isSold': False, 'createdAt': date})
    put('products/' + ident, {'id': ident, 'name': name, 'categoryId': category, 'purchasePrice': price * .8, 'sellingPrice': price, 'quantity': 12 + index, 'barcode': 'DEMO-' + str(index), 'taxPercentage': 14, 'isActive': True, 'createdAt': date, 'updatedAt': date})
put('financial_summary/current', {'totalSales': 128400, 'totalCash': 104800, 'totalCredit': 23600, 'totalTaxesCollected': 15768.42, 'supplierDebt': 12000, 'updatedAt': date})
put('suppliers/demo-supplier', {'id': 'demo-supplier', 'name': 'Demo Supplier', 'phone': '0000000000', 'totalDebt': 12000, 'totalPaid': 38000, 'createdAt': date, 'updatedAt': date})
for index, total in enumerate([18500, 24000, 850, 32000], 1):
    ident = 'demo-order-' + str(index)
    put('orders/' + ident, {'id': ident, 'orderNumber': 'DEMO-00' + str(index), 'orderType': 'cash', 'subtotal': total / 1.14, 'taxAmount': total - total / 1.14, 'total': total, 'paidAmount': total, 'remainingAmount': 0, 'createdAt': date, 'createdByUid': 'demo-admin', 'createdByName': 'Demo Admin'})
print('Seeded fictional POS data. Public demo login: demo@example.com / demo-only-password')
