import pool from '../config/database';

export interface Booking {
  id: number;
  renter_id: number;
  car_id: number;
  start_date: Date;
  end_date: Date;
  total_price: number;
  security_deposit: number;
  status: 'pending' | 'active' | 'completed' | 'cancelled';
  contract_signed: boolean;
  contract_signature_url?: string;
  payment_intent_id?: string;
  payment_status: 'pending' | 'paid' | 'refunded' | 'failed';
  created_at: Date;
  updated_at: Date;
}

export class BookingModel {
  static async create(bookingData: {
    renter_id: number;
    car_id: number;
    start_date: Date;
    end_date: Date;
    total_price: number;
    security_deposit: number;
  }): Promise<Booking> {
    const { renter_id, car_id, start_date, end_date, total_price, security_deposit } = bookingData;

    // Check if car is available for the dates
    const availabilityCheck = await pool.query(
      `SELECT id FROM bookings
       WHERE car_id = $1
       AND status IN ('pending', 'active')
       AND (
         (start_date <= $2 AND end_date >= $2)
         OR (start_date <= $3 AND end_date >= $3)
         OR (start_date >= $2 AND end_date <= $3)
       )`,
      [car_id, start_date, end_date]
    );

    if (availabilityCheck.rows.length > 0) {
      throw new Error('Car is not available for the selected dates');
    }

    const result = await pool.query(
      `INSERT INTO bookings (renter_id, car_id, start_date, end_date, total_price, security_deposit)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [renter_id, car_id, start_date, end_date, total_price, security_deposit]
    );
    return result.rows[0];
  }

  static async findById(id: number): Promise<Booking | null> {
    const result = await pool.query('SELECT * FROM bookings WHERE id = $1', [id]);
    return result.rows[0] || null;
  }

  static async findByRenter(renterId: number): Promise<Booking[]> {
    const result = await pool.query(
      'SELECT * FROM bookings WHERE renter_id = $1 ORDER BY created_at DESC',
      [renterId]
    );
    return result.rows;
  }

  static async findByCar(carId: number): Promise<Booking[]> {
    const result = await pool.query(
      'SELECT * FROM bookings WHERE car_id = $1 ORDER BY created_at DESC',
      [carId]
    );
    return result.rows;
  }

  static async update(id: number, updates: Partial<Booking>): Promise<Booking> {
    const fields = Object.keys(updates);
    const values = Object.values(updates);
    const setClause = fields.map((field, index) => `${field} = $${index + 2}`).join(', ');

    const result = await pool.query(
      `UPDATE bookings SET ${setClause} WHERE id = $1 RETURNING *`,
      [id, ...values]
    );
    return result.rows[0];
  }

  static async delete(id: number): Promise<void> {
    await pool.query('DELETE FROM bookings WHERE id = $1', [id]);
  }

  static async signContract(id: number, signatureUrl: string): Promise<Booking> {
    const result = await pool.query(
      `UPDATE bookings SET contract_signed = true, contract_signature_url = $1 WHERE id = $2 RETURNING *`,
      [signatureUrl, id]
    );
    return result.rows[0];
  }
}








