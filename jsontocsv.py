import csv, sys, json, os

def toCsv(dict_data):
    columns = ['Cluster Name', 'PVC', 'Storage Type', 'Environment', 'Test Name','Thread Count','Reads/s', 'Writes/s', 'read Mb/s', 'write Mb/s', 'Total Time', 'Latency Min', 'Latency Avg', 'Latency Max', 'Latency 95th']
    csv_file = "result.csv"
    try:
        with open(csv_file, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=columns)
            writer.writeheader()
            for data in dict_data:
                writer.writerow(data)
    except IOError:
        print("I/O error")

if __name__=='__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 jsontocsv.py <folder_name>")
        sys.exit(1)
    folderPath = sys.argv[1]+"/"
    filenames=[x[2] for x in os.walk(folderPath)][0]
    allData = []
    for filename in filenames:
    # Opening JSON file
        with open(folderPath+filename) as json_file:
            data = json.load(json_file)
            dict_data = data['log_lines'][0]
            ddata = dict_data.replace("'", "\"")
            if ddata!="":
              allData += json.loads(ddata)
    toCsv(allData)
