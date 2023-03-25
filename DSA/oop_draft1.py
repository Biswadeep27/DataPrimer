#print('hello world')


class Employee():
    company = 'EA Sports'
    def __init__(self,fname,lname,loc) -> None:
        self.first_name = fname
        self.last_name = lname
        self.location = loc
        self.email = f'{self.first_name}.{self.last_name}@fifa.com' 


    def fullname(self):
        return f'{self.first_name} {self.last_name}'


    def set_designation(self,pos):
        print(f'Setting designation for {self.fullname()}')
        desig = f'{pos}_associate'
        return desig




emp1 = Employee('raj','aryan','ban')
emp2 = Employee('arun','ghoshal','kol')

print(emp1.fullname())

print(emp2.fullname())

print(f'designation of {emp1.fullname()} is {emp1.set_designation("DE")}')
