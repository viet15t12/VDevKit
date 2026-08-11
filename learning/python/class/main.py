class Employee:
    raise_amt = 1.04
    num_of_emps = 0
    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.email = first + '.' + last + '@vietnguyen.io.vn'
        self.pay = pay
        Employee.num_of_emps += 1
    def apply_raise(self):
        self.pay = int(self.pay* self.raise_amt)

emp1 = Employee('Corey', 'Schafer', 100)
print(emp1.__dict__)
emp1.raise_amt = 1.5
print(emp1.__dict__)
Employee.raise_amt = 1.05
print(emp1.__dict__)