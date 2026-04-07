import csv
import uuid

USUARIO_ID = '5a8fda51-4eb1-4a66-8efb-cbbee1631b7d'

def fix_num(val):
    if not val:
        return '0'
    return val.replace(',', '.')

with open('ventas.csv', 'r', encoding='utf-8-sig') as fin, \
     open('ventas_import.csv', 'w', newline='', encoding='utf-8') as fout:

    reader = csv.DictReader(fin)
    campos = ['id','usuario_id','fecha','poliza','cliente','tipo_nombre',
              'categoria','precio','valor','puntos','mes','mes_contable',
              'movida','nota_movida']
    writer = csv.DictWriter(fout, fieldnames=campos)
    writer.writeheader()

    for row in reader:
        if not row.get('fecha'):
            continue
        writer.writerow({
            'id': str(uuid.uuid4()),
            'usuario_id': USUARIO_ID,
            'fecha': row['fecha'][:10],
            'poliza': row['poliza'],
            'cliente': row['cliente'],
            'tipo_nombre': row['tipoNombre'],
            'categoria': row['categoria'],
            'precio': fix_num(row['precio']),
            'valor': fix_num(row['valor']),
            'puntos': fix_num(row['puntos']),
            'mes': row['mes'][:7] if row['mes'] else '',
            'mes_contable': row['mesContable'][:7] if row['mesContable'] else '',
            'movida': 'true' if row['movida'] in ['TRUE','true','1','True'] else 'false',
            'nota_movida': row.get('notaMovida','')
        })

print("✅ Archivo ventas_import.csv creado correctamente")
