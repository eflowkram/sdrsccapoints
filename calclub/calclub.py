#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
import argparse
from dateutil import parser
import json
import sys
import os
import sqlite3
from sqlite3 import Error

database_name = 'points.db'
non_points = ['TO','X']


class_results_table = """
CREATE TABLE class_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_date date,
    driver_id int(10),
    class varchar(10),
    place int(10),
    final_time decimal(10,3),
    points decimal(10,3),
    national BOOLEAN DEFAULT 0 CHECK (national IN (0, 1)),
    unique (event_date,driver_id)
);
"""

drivers_table = """
CREATE TABLE drivers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_name varchar(50),
    car_number int(10) unique
);
"""

points_table = """
CREATE TABLE points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id int(10),
    class varchar(10),
    points decimal(10,3),
    unique (driver_id,class)
);
"""


def create_connection(path):
    connection = None
    try:
        connection = sqlite3.connect(path)
        print("Connection to SQLite DB successful")
    except Error as e:
        print(f"The error '{e}' occurred")

    return connection


def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        print("Query executed successfully")
        return cursor.lastrowid
    except Error as e:
        print(f"The error '{e}' occurred")


def execute_read_query(connection, query):
    cursor = connection.cursor()
    result = None
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    except Error as e:
        print(f"The error '{e}' occurred")


def update_average_points(driver_id, car_class):
    sum_points = float()
    sql = f"SELECT points from class_results where class = '{car_class}' and driver_id = '{driver_id}' and national = 0"
    points = execute_read_query(db_conn, sql)
    points_count = len(points)
    for n in points:
        sum_points += n[0]
    avg_points = sum_points / points_count
    avg_points=round(avg_points,3)
    sql = f"UPDATE class_results set points = {avg_points} where  class = '{car_class}' and driver_id = '{driver_id}' and national = 1"
    execute_query(db_conn, sql)
    return

def calclub_drops(events):
    if events < 4:
      return 0
    elif events < 7:
      return 1
    elif events < 11:
      return 2
    elif events < 14:
      return 3
    elif events < 17:
      return 4
    else:
       return 5

def total_class_points(driver_id,car_class):
    rp=[]
    sql=f"select points from class_results where driver_id={driver_id} and class='{car_class}'"
    class_points_results=execute_read_query(db_conn,sql)
    drops=calclub_drops(len(class_points_results))
    print(f"no events: {len(class_points_results)} drops: {drops}")
    count=len(class_points_results) - drops
    for p in class_points_results:
        rp.append(p[0])
    rp.sort(reverse=True)
    rp=rp[:count]
    print(rp)
    tp = round(sum(rp),3)
    print(f"total points: {tp}")
    return tp

def listToString(s):
    string = ''
    for element in s:
        string += element
    return string


def calclubpoints(fastest, driver):
    points_scored = 100 - 400 * ((driver - fastest) / fastest)
    if points_scored < 0:
        points_scored = 0
    return round(points_scored, 3)


def table_data(table_handle):
    return [[cell.text.strip() for cell in row.find_all(["th", "td"])]
            for row in table_handle.find_all("tr")]


def get_event_date(table_handle):
    header_data = table_data(table_handle)
    header_data = listToString(header_data[1])
    return header_data[len(header_data) - 10:]

if not os.path.isfile(database_name):
    db_conn = create_connection(database_name)
    execute_query(db_conn, class_results_table)
    execute_query(db_conn, drivers_table)
    execute_query(db_conn, points_table)
else:
    db_conn = create_connection(database_name)


def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument(
        "-u",
        "--url",
        help="url to axware html",
        action='store',
        dest='url',
        default=None,
        required=False)
    argparser.add_argument(
        "-n",
        "--national",
        help="car number for national",
        dest='national',
        default=None,
        required=False)
    argparser.add_argument(
        "-c",
        "--car_class",
        help="class for national",
        default=None,
        required=False)
    argparser.add_argument(
        "-d",
        "--event_date",
        help="event_date",
        default=None,
        required=False)
    argparser.add_argument(
        "-g",
        "--generate",
        help="generate points",
        action='store_true',
        default=None,
        required=False)
    argparser.add_argument(
        "-p",
        "--print_points",
        help="Display points, can be used with -c/--car_class",
        action='store_true',
        required=False)
    args = argparser.parse_args()

    if args.url:
        r = requests.get(args.url)
        soup = BeautifulSoup(r.content, 'html.parser')
        event_date = get_event_date(soup.find_all('table')[0])
        print(f"ed: {event_date}")

        class_table = soup.find_all('table')[2]
        # = [[cell.text.strip() for cell in row.find_all(["th","td"])]
        #                        for row in class_table.find_all("tr")]i

        class_data = table_data(class_table)
        for item in class_data:
            first_element = listToString(item[0])
            if len(first_element) == 0:
                continue
            if first_element[0].isalpha():
                car_class = first_element.split(' ')[0]
                if car_class not in non_points:
                    print(f"Class: {car_class}")
                continue
            if car_class in non_points:
                continue
            car_number = int(item[2])
            if car_number >= 600 and car_number <= 699:
                continue
            position = first_element.replace('T', '')
            if position == '1':
                winner_time = float(item[12])
                print(f"winner_time: {winner_time}")
            driver = item[3].replace("'","")
            final_time = item[12]
            if item[12] != 'DNS':
                points = calclubpoints(winner_time, float(item[12]))
                print(
                    f"Event Date: {event_date} Position: {position} Class: {car_class} Car No: {car_number} Driver: {driver} Points: {points}")
                # Create driver record if it doesn't exist
                sql = f"SELECT id from drivers where car_number = '{car_number}'"
                driver_results = execute_read_query(db_conn, sql)
                if len(driver_results) == 0:
                    sql = f"INSERT into drivers VALUES (NULL,'{driver}',{car_number})"
                    driver_id = execute_query(db_conn, sql)
                else:
                    driver_id = driver_results[0][0]
                sql = f"INSERT INTO class_results VALUES (NULL,'{event_date}',{driver_id},'{car_class}',{position},{final_time},{points},0)"
                execute_query(db_conn, sql)

    if args.national:
        event_date = args.event_date
        car_number = args.national
        car_class = args.car_class.upper()
        # event_date.
        sql = f"SELECT class_results.id,drivers.id from class_results JOIN drivers on drivers.id = driver_id where event_date = '{event_date}' and class = '{car_class}' and car_number = '{car_number}'"
        results = execute_read_query(db_conn, sql)
        if len(results) == 0:
            print('no record found, adding record.')
            # get driver_id
            sql = f"SELECT id from drivers where car_number = '{car_number}'"
            results = execute_read_query(db_conn, sql)
            driver_id = results[0][0]
            sql = f"INSERT into class_results VALUES (NULL,'{event_date}',{driver_id},'{car_class}',0,0,0,1)"
            results = execute_query(db_conn, sql)
            update_average_points(driver_id, car_class)
        else:
            print("Records Found, updating average")
            driver_id = results[0][1]
            update_average_points(driver_id,car_class)

    if args.generate:
        """
          zero points table
          get all driver ids
          query class results, pull driver id, car class
          pass driver id and class to total points function which will calculate drops and return total points for driver/class. 
          calculate points for class with drops and store in points table.
        """
        # zero points table
        sql = "delete from points"
        execute_query(db_conn,sql)
        sql = "Select id from drivers order by id asc"
        driver_id_results = execute_read_query(db_conn,sql)
        for i in driver_id_results:
          driver_id=i[0]
          sql=f"select distinct class from class_results where driver_id={driver_id}"
          driver_class_results=execute_read_query(db_conn,sql)
          for c in driver_class_results:
            car_class=c[0]
            update_average_points(driver_id,car_class)
            print(f"driver_id: {driver_id} class: {c[0]}")
            total_points=total_class_points(driver_id,c[0])
            sql=f"INSERT into points values (NULL,{driver_id},'{car_class}',{total_points})"
            result=execute_query(db_conn,sql)
          
    if args.print_points:
        car_class=[]
        if args.car_class:
          car_class.append(args.car_class.upper())
        else:
          sql=f"SELECT distinct class from points order by class ASC"
          results=execute_read_query(db_conn,sql)
          for cc in results:
            car_class.append(cc[0])
        for c in car_class:
          class_sql=f"SELECT driver_name,car_number,class,points from points join drivers on drivers.id=points.driver_id where class='{c}' order by points DESC"
          results=execute_read_query(db_conn,class_sql)
          p=1
          print(f"\n{'Place' : <10}{'Driver' : <25}{'Car Number' : <15}{'Class' : <10}{'Points' : <20}")
          for l in results:
            print(f"{p : <10}{l[0] : <25}{l[1] : <15}{l[2] : <10}{l[3] : <20}")
            p+=1

if __name__ == '__main__':
    main()
