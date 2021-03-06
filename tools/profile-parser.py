#!/usr/bin/env python3

"""
Parse output of the Ansible profile_tasks module, and save as a CSV file.
"""

import csv
from datetime import datetime
import re
import sys


class Task(object):
    def __init__(self):
        self.name = None
        self.role = None
        self.play = None
        self.timestamp = None
        self.duration = None
        self.elapsed = None
        self.ok = 0
        self.skipping = 0
        self.fatal = 0
        self.changed = 0

    @staticmethod
    def write_header(csv_writer):
        csv_writer.writerow(["Timestamp", "Duration", "Elapsed", "Play", "Role", "Task", "ok", "changed", "skipped", "failed"])

    def write(self, csv_writer):
        csv_writer.writerow([
            self.timestamp,
            self._seconds(self.duration),
            self._seconds(self.elapsed),
            self.play,
            self.role,
            self.task,
            self.ok,
            self.changed,
            self.skipping,
            self.fatal])

    @staticmethod
    def _seconds(time):
        if not time:
            return -1
        return ((time.hour * 60) + time.minute) * 60 + time.second + (float(time.microsecond) / 1000000)


def main():
    in_path = sys.argv[1]
    print("Input: {}".format(in_path))
    out_path = sys.argv[2]
    with open(in_path) as f:
        logs = f.readlines()
    with open(out_path, 'w') as f:
        writer = csv.writer(f)
        parse(logs, writer)


def parse(logs, csv_writer):
    Task.write_header(csv_writer)
    play = None
    task = None
    task_pattern = re.compile(r'^(TASK|PLAY) \[((.*) : )?(.*)\] \*+')
    # e.g. Friday 19 June 2020  19:02:52 +0100 (0:00:00.031)       0:00:00.031 ***********
    profile_pattern = re.compile(r'^(.*) \((.*)\) *([^ ]*) \*+')
    host_pattern = re.compile(r'^(ok|changed|skipping|fatal): \[(.*)\]')
    for index, line in enumerate(logs):
        match = task_pattern.search(line)
        if match:
            if match.group(1) == 'TASK':
                if task:
                    # Complete the previous task.  Grab profiling information
                    # from the following line
                    profile_match = profile_pattern.search(logs[index+1])
                    if not profile_match:
                        #print("Expected to find profile in {}".format(logs[index+1])
                        pass
                    else:
                        #print(profile_match.groups())
                        task.timestamp, duration, elapsed = profile_match.groups()
                        task.duration = datetime.strptime(duration, "%H:%M:%S.%f").time()
                        task.elapsed = datetime.strptime(elapsed, "%H:%M:%S.%f").time()
                        #print("Task {} role {} duration {}".format(task, role, duration))

                    # Write task to CSV.
                    task.write(csv_writer)

                # Start the new task.
                task = Task()
                task.play = play
                task.task = match.group(4)
                task.role = match.group(3)
            else:
                assert match.group(1) == 'PLAY'
                play = match.group(4)
            #print(match.groups())
            continue

        match = host_pattern.search(line)
        if match:
            status = match.group(1)
            setattr(task, status, getattr(task, status) + 1)
            continue

        #print("Ignoring line", line)


if __name__ == "__main__":
    main()
