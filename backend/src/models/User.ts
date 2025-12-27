import pool from '../config/database';

export interface User {
  id: number;
  name: string;
  email: string;
  phone?: string;
  role: 'renter' | 'host';
  is_verified: boolean;
  rating: number;
  profile_image_url?: string;
  created_at: Date;
  updated_at: Date;
}

export class UserModel {
  static async create(userData: {
    name: string;
    email: string;
    phone?: string;
    role?: 'renter' | 'host';
  }): Promise<User> {
    const { name, email, phone, role = 'renter' } = userData;
    const result = await pool.query(
      `INSERT INTO users (name, email, phone, role)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [name, email, phone, role]
    );
    return result.rows[0];
  }

  static async findByEmail(email: string): Promise<User | null> {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0] || null;
  }

  static async findById(id: number): Promise<User | null> {
    const result = await pool.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  static async update(id: number, updates: Partial<User>): Promise<User> {
    const fields = Object.keys(updates);
    const values = Object.values(updates);
    const setClause = fields.map((field, index) => `${field} = $${index + 2}`).join(', ');
    
    const result = await pool.query(
      `UPDATE users SET ${setClause} WHERE id = $1 RETURNING *`,
      [id, ...values]
    );
    return result.rows[0];
  }
}








