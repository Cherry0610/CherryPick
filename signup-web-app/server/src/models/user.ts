import { v4 as uuidv4 } from 'uuid';

export interface User {
  id: string;
  username: string;
  email: string;
  password: string; // In a real application, ensure to hash passwords
}

export class UserModel {
  private users: User[];

  constructor() {
    this.users = this.loadUsers();
  }

  private loadUsers(): User[] {
    // Load users from the JSON file (this should be replaced with a database in a real app)
    const usersData = require('../db/users.json');
    return usersData as User[];
  }

  public getAllUsers(): User[] {
    return this.users;
  }

  public createUser(username: string, email: string, password: string): User {
    const newUser: User = {
      id: uuidv4(),
      username,
      email,
      password, // Remember to hash this in a real application
    };
    this.users.push(newUser);
    this.saveUsers();
    return newUser;
  }

  private saveUsers(): void {
    // Save users to the JSON file (this should be replaced with a database in a real app)
    const fs = require('fs');
    fs.writeFileSync('../db/users.json', JSON.stringify(this.users, null, 2));
  }
}