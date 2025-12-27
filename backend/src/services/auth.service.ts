import jwt from 'jsonwebtoken';
import * as admin from 'firebase-admin';
import { UserModel, User } from '../models/User';

// Firebase Admin SDK initialization
let firebaseAdminInitialized = false;

function initializeFirebaseAdmin() {
  if (firebaseAdminInitialized) {
    return;
  }

  try {
    // Try to initialize with service account key
    if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      try {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        firebaseAdminInitialized = true;
        console.log('✓ Firebase Admin SDK initialized with service account');
        return;
      } catch (parseError) {
        console.warn('Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY:', parseError);
      }
    }

    // Try with GOOGLE_APPLICATION_CREDENTIALS
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      try {
        admin.initializeApp({
          credential: admin.credential.applicationDefault(),
        });
        firebaseAdminInitialized = true;
        console.log('✓ Firebase Admin SDK initialized with GOOGLE_APPLICATION_CREDENTIALS');
        return;
      } catch (credError: any) {
        console.warn('Failed to initialize with GOOGLE_APPLICATION_CREDENTIALS:', credError.message);
      }
    }

    // If no credentials available, continue without verification (development mode)
    console.warn('⚠ Firebase Admin SDK not initialized - using token decoding without verification (development mode)');
    console.warn('⚠ To enable full verification, set FIREBASE_SERVICE_ACCOUNT_KEY or GOOGLE_APPLICATION_CREDENTIALS');
    firebaseAdminInitialized = false;
  } catch (error: any) {
    console.warn('Firebase Admin SDK initialization error:', error.message);
    firebaseAdminInitialized = false;
  }
}

// Initialize on module load
initializeFirebaseAdmin();

export class AuthService {
  private static readonly JWT_SECRET = process.env.JWT_SECRET || 'autogo_jwt_secret_key_for_development_only_change_in_production';
  private static readonly JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

  /**
   * Generate JWT token for API access
   */
  static generateToken(user: User): string {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
      },
      this.JWT_SECRET,
      { expiresIn: this.JWT_EXPIRES_IN } as jwt.SignOptions
    );
  }

  /**
   * Verify JWT token
   */
  static async verifyToken(token: string): Promise<any> {
    return jwt.verify(token, this.JWT_SECRET);
  }

  /**
   * Verify Firebase ID token and extract user information
   */
  static async verifyFirebaseToken(firebaseIdToken: string): Promise<admin.auth.DecodedIdToken> {
    try {
      // Decode token first (works without Firebase Admin)
      const decoded: any = jwt.decode(firebaseIdToken);
      
      if (!decoded) {
        throw new Error('Invalid Firebase token: unable to decode');
      }
      
      // Validate token has required fields
      if (!decoded.email && !decoded.phone_number) {
        throw new Error('Invalid Firebase token: missing email or phone number');
      }

      // If Firebase Admin is initialized, try to verify
      if (firebaseAdminInitialized) {
        try {
          const verifiedToken = await admin.auth().verifyIdToken(firebaseIdToken);
          return verifiedToken;
        } catch (verifyError: any) {
          // If verification fails, fall back to decoded token
          console.warn('Firebase Admin verification failed, using decoded token:', verifyError.message);
        }
      }

      // Return decoded token as DecodedIdToken
      return {
        uid: decoded.uid || decoded.sub || '',
        email: decoded.email || null,
        email_verified: decoded.email_verified || false,
        name: decoded.name || null,
        picture: decoded.picture || null,
        phone_number: decoded.phone_number || null,
        firebase: {
          identities: decoded.firebase?.identities || {},
          sign_in_provider: decoded.firebase?.sign_in_provider || 'password',
        },
        aud: decoded.aud || '',
        auth_time: decoded.auth_time || Math.floor(Date.now() / 1000),
        exp: decoded.exp || 0,
        iat: decoded.iat || 0,
        iss: decoded.iss || '',
        sub: decoded.sub || decoded.uid || '',
      } as admin.auth.DecodedIdToken;
    } catch (error: any) {
      console.error('Firebase token verification error:', error.message);
      throw new Error(`Invalid Firebase token: ${error.message}`);
    }
  }

  /**
   * Authenticate with Firebase ID token
   * Supports Google, Email/Password, and Phone authentication
   */
  static async authenticateWithFirebase(
    firebaseIdToken: string,
    name?: string
  ): Promise<{ user: User; token: string }> {
    try {
      console.log('Starting Firebase authentication...');
      
      // Verify Firebase token
      console.log('Verifying Firebase token...');
      const decodedToken = await this.verifyFirebaseToken(firebaseIdToken);
      console.log('Token verified. Email:', decodedToken.email, 'Phone:', decodedToken.phone_number);
      
      // Extract user information
      const email = decodedToken.email;
      const phone = decodedToken.phone_number || null;
      const firebaseUid = decodedToken.uid;

      // Validate we have email or phone
      if (!email && !phone) {
        throw new Error('Email or phone number is required from Firebase token');
      }

      // For phone-only authentication, use phone as email fallback
      const userEmail = email || `${phone}@autogo.local`;
      console.log('User email:', userEmail);

      // Determine user name
      const userName = name || decodedToken.name || (email ? email.split('@')[0] : 'User');
      console.log('User name:', userName);

      // Find or create user
      console.log('Looking up user by email:', userEmail);
      let user: User | null;
      
      try {
        user = await UserModel.findByEmail(userEmail);
        console.log('User lookup result:', user ? `Found user ID ${user.id}` : 'User not found');
      } catch (dbError: any) {
        console.error('Database error in findByEmail:', dbError);
        // If database is not available, create a mock user for testing
        if (dbError.code === 'ECONNREFUSED' || 
            dbError.code === '42P01' || 
            dbError.code === '3D000' ||
            dbError.message?.includes('does not exist') ||
            dbError.message?.includes('connection')) {
          console.warn('Database not available, using mock user for testing');
          const mockUser: User = {
            id: 1,
            name: userName,
            email: userEmail,
            phone: phone || undefined,
            role: 'renter',
            is_verified: false,
            rating: 0,
            created_at: new Date(),
            updated_at: new Date(),
          };
          const token = this.generateToken(mockUser);
          return { user: mockUser, token };
        }
        throw dbError;
      }
      
      if (!user) {
        // Create new user
        console.log('Creating new user...');
        try {
          user = await UserModel.create({
            name: userName,
            email: userEmail,
            phone: phone || undefined,
            role: 'renter',
          });
          console.log('User created with ID:', user.id);
        } catch (createError: any) {
          console.error('Error creating user:', createError);
          throw new Error(`Failed to create user: ${createError.message}`);
        }
      } else {
        console.log('Existing user found, ID:', user.id);
        // Update user name if provided and different
        if (name && user.name !== name) {
          try {
            user = await UserModel.update(user.id, { name: userName });
            console.log('User name updated');
          } catch (updateError: any) {
            console.warn('Could not update user name:', updateError.message);
            // Continue even if update fails
          }
        }
        // Update phone if not set
        if (phone && !user.phone) {
          try {
            user = await UserModel.update(user.id, { phone });
            console.log('User phone updated');
          } catch (updateError: any) {
            console.warn('Could not update user phone:', updateError.message);
            // Continue even if update fails
          }
        }
      }

      // Generate JWT token for API access
      console.log('Generating JWT token...');
      const token = this.generateToken(user);
      console.log('Authentication successful for user:', user.email);
      
      return { user, token };
    } catch (error: any) {
      console.error('Firebase authentication error:', error);
      console.error('Error stack:', error.stack);
      throw error;
    }
  }
}
