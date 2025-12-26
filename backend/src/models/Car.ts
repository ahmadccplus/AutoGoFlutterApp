import pool from '../config/database';

export interface Car {
  id: number;
  owner_id: number;
  make: string;
  model: string;
  year: number;
  price_per_day: number;
  price_per_hour?: number;
  location_latitude?: number;
  location_longitude?: number;
  location_address?: string;
  images: string[];
  is_available: boolean;
  seats?: number;
  doors?: number;
  transmission?: 'automatic' | 'manual';
  fuel_type?: 'petrol' | 'diesel' | 'electric' | 'hybrid';
  air_conditioning: boolean;
  mileage_limit?: number;
  description?: string;
  specs?: any;
  created_at: Date;
  updated_at: Date;
}

export class CarModel {
  static async create(carData: Partial<Car>): Promise<Car> {
    const {
      owner_id,
      make,
      model,
      year,
      price_per_day,
      price_per_hour,
      location_latitude,
      location_longitude,
      location_address,
      images,
      seats,
      doors,
      transmission,
      fuel_type,
      air_conditioning,
      mileage_limit,
      description,
      specs,
    } = carData;

    const result = await pool.query(
      `INSERT INTO cars (
        owner_id, make, model, year, price_per_day, price_per_hour,
        location_latitude, location_longitude, location_address, images,
        seats, doors, transmission, fuel_type, air_conditioning,
        mileage_limit, description, specs
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      RETURNING *`,
      [
        owner_id,
        make,
        model,
        year,
        price_per_day,
        price_per_hour,
        location_latitude,
        location_longitude,
        location_address,
        images || [],
        seats,
        doors,
        transmission,
        fuel_type,
        air_conditioning || false,
        mileage_limit,
        description,
        specs ? JSON.stringify(specs) : null,
      ]
    );
    return result.rows[0];
  }

  static async findById(id: number): Promise<Car | null> {
    const result = await pool.query('SELECT * FROM cars WHERE id = $1', [id]);
    return result.rows[0] || null;
  }

  static async search(filters: {
    location?: string;
    start_date?: string;
    end_date?: string;
    min_price?: number;
    max_price?: number;
    make?: string;
    transmission?: string;
    fuel_type?: string;
    page?: number;
    limit?: number;
  }): Promise<{ cars: Car[]; total: number }> {
    const {
      location,
      start_date,
      end_date,
      min_price,
      max_price,
      make,
      transmission,
      fuel_type,
      page = 1,
      limit = 20,
    } = filters;

    let query = 'SELECT * FROM cars WHERE is_available = true';
    const params: any[] = [];
    let paramCount = 1;

    if (location) {
      query += ` AND location_address ILIKE $${paramCount}`;
      params.push(`%${location}%`);
      paramCount++;
    }

    if (min_price) {
      query += ` AND price_per_day >= $${paramCount}`;
      params.push(min_price);
      paramCount++;
    }

    if (max_price) {
      query += ` AND price_per_day <= $${paramCount}`;
      params.push(max_price);
      paramCount++;
    }

    if (make) {
      query += ` AND make ILIKE $${paramCount}`;
      params.push(`%${make}%`);
      paramCount++;
    }

    if (transmission) {
      query += ` AND transmission = $${paramCount}`;
      params.push(transmission);
      paramCount++;
    }

    if (fuel_type) {
      query += ` AND fuel_type = $${paramCount}`;
      params.push(fuel_type);
      paramCount++;
    }

    // Check availability for date range
    if (start_date && end_date) {
      query += ` AND id NOT IN (
        SELECT car_id FROM bookings
        WHERE status IN ('pending', 'active')
        AND (
          (start_date <= $${paramCount} AND end_date >= $${paramCount + 1})
          OR (start_date <= $${paramCount + 1} AND end_date >= $${paramCount})
        )
      )`;
      params.push(start_date, end_date);
      paramCount += 2;
    }

    const countResult = await pool.query(
      `SELECT COUNT(*) FROM (${query}) as count_query`,
      params
    );
    const total = parseInt(countResult.rows[0].count);

    query += ` ORDER BY created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(limit, (page - 1) * limit);

    const result = await pool.query(query, params);
    return { cars: result.rows, total };
  }

  static async findByOwner(ownerId: number): Promise<Car[]> {
    const result = await pool.query(
      'SELECT * FROM cars WHERE owner_id = $1 ORDER BY created_at DESC',
      [ownerId]
    );
    return result.rows;
  }

  static async update(id: number, updates: Partial<Car>): Promise<Car> {
    const fields = Object.keys(updates);
    const values = Object.values(updates);
    const setClause = fields.map((field, index) => `${field} = $${index + 2}`).join(', ');

    const result = await pool.query(
      `UPDATE cars SET ${setClause} WHERE id = $1 RETURNING *`,
      [id, ...values]
    );
    return result.rows[0];
  }

  static async delete(id: number): Promise<void> {
    await pool.query('DELETE FROM cars WHERE id = $1', [id]);
  }
}



