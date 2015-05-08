#!/usr/bin/python
from copy import deepcopy

#Citys to visit
route = []
#Possible paths to visit the citys
paths = []
#Critical citys, citys with only one connection
critical = []
#Flight and path Graph
flight_graph = {}
#Info flight dictionary
flights_info = {}

def main():
    global route
    global start_day
    global num_flights_day
    global return_day
    check_graph()
    graph_of_flight_info()
    route,start_day,num_flights_day,return_day = route_plan()
    make_all_path(route[0],route[-1],[route[0]])
    if len(route) > 2:
        check_city_path()
    make_tree_of_flight(start_day,return_day,num_flights_day)

def check_graph():
    for city in graph.keys():
        if len(graph[city]) == 1:
            critical.append(city)

def graph_of_flight_info():
    for key in flight.keys():
        for value in flight[key]:
                flights_info[value[2]] = [value[0],value[1],value[3]]

def make_tree_of_flight(start_day,return_day,num_flights_day):
    for path in paths:
        flight_graph.clear()
        flight_graph["start"] = []
        make_tree_of_flight_aux(path,None,start_day,return_day,num_flights_day,0)
        print "\nPath: "
        print path
        print "Flight: "
        for key in flight_graph.keys():
			print key,"-> ",flight_graph[key]
        print "\n#################################"
            
def make_tree_of_flight_aux(path,father,start_day,return_day,num_flights_day,deep):    
    if len(path) >= 2:  
        flights_description = flight[(path[0],path[1])]
        for one_flight_description in flights_description:
            fly_son = flights_info[one_flight_description[2]]
            if father == None:
                if start_day in fly_son[2] or 0 in fly_son[2] or start_day == 0:
                    flight_graph["start"].append(one_flight_description[2])
                else:
                    continue
            else:
                fly_father = flights_info[father] 
                if bigger_equal_than(fly_son[2],fly_father[2]) or 0 in fly_son[2]: 
                    if not flight_graph.has_key(father):
                        flight_graph[father] = [one_flight_description[2]]
                    else:
                        if one_flight_description[2] not in flight_graph[father]:
                            if deep == return_day or return_day == 0: 
                                flight_graph[father].append(one_flight_description[2])
                            else:
                                flight_graph[father].append(one_flight_description[2])
                else:
                    if flight_graph.has_key(father):
                        if flight_graph[father] == []:
                            del_by_father(father)
                    else:
                        del_by_father(father)
                    continue                      
            deep += 1
            make_tree_of_flight_aux(path[1:],one_flight_description[2],start_day,return_day,num_flights_day,deep)

def bigger_equal_than(son,father):
    for f in father:
        for s in son:
            if s >= f or f == 0:
                return True
    return False
            
def del_by_father(val):
    for keys in flight_graph.keys():
        for values in flight_graph[keys]:
            if val in values:
                flight_graph[keys].remove(val)
                return
            
            
def make_all_path(origin,destination,path):
    for son in graph[origin]:
        if son not in path or (path[0] == destination and son == path[0]) or path[-1] in critical:
            path.append(son)
            if son == destination:
                paths.append(deepcopy(path))
                path.pop()
                continue
            make_all_path(son,destination,path)
    path.pop() 

#Check unnecessary travels
def check_city_path():
    to_delete = []
    for city in route:
        for path in paths:
            if path not in to_delete:
                if city not in path:
                    to_delete.append(path)
    for crit in critical:
        for path in paths:
            if path not in to_delete:
                if crit in path and crit not in route:
                    to_delete.append(path)
    for delete in to_delete:
        paths.remove(delete)
    
def sum_days(start_day,end_day):
    if start_day < end_day:
        return end_day - start_day
    else:
        if start_day > end_day:
            return (7 - start_day + end_day)
        else:
            return 0
        
def next_day(start_day):
    if start_day < 7 and start_day > 0:
        return start_day + 1
    else:
        if start_day == 7:
            return 1
    
def route_plan():
    route = []
    #From...
    city_list()    
    route.append(int(raw_input("From: ").strip()))
    #TO...
    add_more = 1
    while add_more <> 0:
        print "**************************************"
        city_list()
        destination = int(raw_input("To: ").strip())
        route.append(destination)
        print "**************************************\n"
        print "Add more destinations?"
        print "0 -> No"
        print "1 -> Yes"
        add_more = int(raw_input("Number: ").strip())

    #Start_day
    print "**************************************\n"
    print "Day of departure"
    day_list()
    start_day = int(raw_input("Day: ").strip())
    
    #Day of return
    print "**************************************\n"
    print "Day of last flight?\n"
    day_list()
    return_day = int(raw_input("Day: ").strip())
    
    #Number of flights in one day
    print "**************************************\n"
    print "Number of flighs per day?"
    num_flights_day=int(raw_input("Number: ").strip())
    
    return (route,start_day,num_flights_day,return_day)

def day_list():
    print "\nDay List..."
    print "1 -> Sunday"
    print "2 -> Monday"
    print "3 -> Tuesday"
    print "4 -> Wednesday"
    print "5 -> Thursday"
    print "6 -> Friday"
    print "7 -> Saturday"
    print "0 -> All days\n"

def city_list():
    print "\nCity List..."
    print "1 -> London"
    print "2 -> Zurich"
    print "3 -> Milan"
    print "4 -> Ljubljana"
    print "5 -> Edinburgh\n"

#Data
graph={}
graph[1] = [5,4,3,2]
graph[2] = [1,3,4]
graph[3] = [1,2]
graph[4] = [1,2]
graph[5] = [1]
city={}
city[1]="London"
city[2]="Zurich"
city[3]="Milan"
city[4]="Ljubljana"
city[5]="Edinburgh"
flight={}
        
#From 1 London
flight[(1,5)] = [[940,1050,'ba4732',[0]],[1140,1250,'ba4752',[0]],[1840,1950,'ba4822',[2,3,4,5,6]]]
flight[(1,4)] = [[1320,1620,'ju201',[6]],[1320,1620,'ju213',[1]]]
flight[(1,2)] = [[910,1145,'ba614',[0]],[1445,1720,'sr805',[0]]]
flight[(1,3)] = [[830,1120,'ba510',[0]],[1100,1350,'az459',[0]]]
#From 2 Zurich
flight[(2,4)] = [[1330,1440,'yu323',[3,5]]]
flight[(2,1)] = [[900,940,'ba613',[2,3,4,5,6,7]],[1610,1655,'sr806',[2,3,4,5,6,1]]]
flight[(2,3)] = [[755,845,'sr620',[0]]]
#From 3 Milan
flight[(3,1)] = [[910,1000,'az458',[0]],[1220,1310,'ba511',[0]]]
flight[(3,2)] = [[925,1015,'sr621',[0]],[1245,1335,'sr623',[0]]]
#From 4 Ljubljana
flight[(4,2)] = [[1130,1240,'ju322',[3,5]]]
flight[(4,1)] = [[1110,1220,'yu200',[6]],[1125,1220,'yu212',[1]]]
#From 5 Edinburgh
flight[(5,1)] = [[940,1050,'ba4733',[0]],[1340,1450,'ba4773',[0]],[1940,2050,'ba4833',[2,3,4,5,6,1]]]

if __name__ == '__main__':
    main()
