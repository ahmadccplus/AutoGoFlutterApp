import { AuthService } from '../src/services/auth.service';
import { UserModel } from '../src/models/User';
import * as jwt from 'jsonwebtoken';

// Mock dependencies
jest.mock('../src/models/User');
jest.mock('jsonwebtoken');
jest.mock('firebase-admin', () => ({
  auth: jest.fn(() => ({
    verifyIdToken: jest.fn(),
  })),
  credential: {
    cert: jest.fn(),
    applicationDefault: jest.fn(),
  },
  initializeApp: jest.fn(),
}));

describe('AuthService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Set default JWT secret for testing
    process.env.JWT_SECRET = 'test_secret_key';
  });

  describe('generateToken', () => {
    it('should generate a valid JWT token for a user', () => {
      // Arrange
      const mockUser = {
        id: 1,
        email: 'test@example.com',
        role: 'renter' as const,
        name: 'Test User',
        is_verified: false,
        rating: 0,
        created_at: new Date(),
        updated_at: new Date(),
      };

      const mockToken = 'generated_jwt_token';
      (jwt.sign as jest.Mock).mockReturnValue(mockToken);

      // Act
      const token = AuthService.generateToken(mockUser);

      // Assert
      expect(token).toBe(mockToken);
      expect(jwt.sign).toHaveBeenCalledWith(
        {
          userId: mockUser.id,
          email: mockUser.email,
          role: mockUser.role,
        },
        'test_jwt_secret',
        { expiresIn: '7d' }
      );
    });

    it('should use JWT secret from environment', () => {
      // Arrange
      // Note: JWT_SECRET is set in setup.ts and read at class load time
      // This test verifies it uses the environment variable
      const mockUser = {
        id: 1,
        email: 'test@example.com',
        role: 'renter' as const,
        name: 'Test User',
        is_verified: false,
        rating: 0,
        created_at: new Date(),
        updated_at: new Date(),
      };

      // Clear previous calls
      (jwt.sign as jest.Mock).mockClear();

      // Act
      AuthService.generateToken(mockUser);

      // Assert - should use the secret from setup.ts (test_jwt_secret)
      expect(jwt.sign).toHaveBeenCalledWith(
        expect.any(Object),
        'test_jwt_secret', // From setup.ts
        expect.any(Object)
      );
    });
  });

  describe('verifyToken', () => {
    it('should verify a valid JWT token', async () => {
      // Arrange
      const token = 'valid_jwt_token';
      const decoded = { userId: 1, email: 'test@example.com', role: 'renter' };
      (jwt.verify as jest.Mock).mockReturnValue(decoded);

      // Act
      const result = await AuthService.verifyToken(token);

      // Assert
      expect(result).toEqual(decoded);
      expect(jwt.verify).toHaveBeenCalledWith(token, 'test_jwt_secret');
    });

    it('should throw error for invalid token', async () => {
      // Arrange
      const token = 'invalid_token';
      (jwt.verify as jest.Mock).mockImplementation(() => {
        throw new Error('Invalid token');
      });

      // Act & Assert
      await expect(AuthService.verifyToken(token)).rejects.toThrow('Invalid token');
    });
  });

  describe('verifyFirebaseToken', () => {
    it('should decode Firebase token when Firebase Admin is not initialized', async () => {
      // Arrange
      const mockToken = 'firebase_token';
      const decodedToken = {
        uid: 'firebase_uid',
        email: 'test@example.com',
        email_verified: true,
        name: 'Test User',
        sub: 'firebase_uid',
        aud: 'project_id',
        iss: 'https://securetoken.google.com/project_id',
        exp: Math.floor(Date.now() / 1000) + 3600,
        iat: Math.floor(Date.now() / 1000),
        auth_time: Math.floor(Date.now() / 1000),
        firebase: {
          identities: { email: ['test@example.com'] },
          sign_in_provider: 'password',
        },
      };

      (jwt.decode as jest.Mock).mockReturnValue(decodedToken);

      // Act
      const result = await AuthService.verifyFirebaseToken(mockToken);

      // Assert
      expect(result).toBeDefined();
      expect(result.email).toBe('test@example.com');
      expect(result.uid).toBe('firebase_uid');
      expect(jwt.decode).toHaveBeenCalledWith(mockToken);
    });

    it('should throw error when token cannot be decoded', async () => {
      // Arrange
      const mockToken = 'invalid_token';
      (jwt.decode as jest.Mock).mockReturnValue(null);

      // Act & Assert
      await expect(AuthService.verifyFirebaseToken(mockToken)).rejects.toThrow(
        'Invalid Firebase token: unable to decode'
      );
    });

    it('should throw error when token has no email or phone', async () => {
      // Arrange
      const mockToken = 'token_without_email';
      const decodedToken = {
        uid: 'firebase_uid',
        sub: 'firebase_uid',
      };

      (jwt.decode as jest.Mock).mockReturnValue(decodedToken);

      // Act & Assert
      await expect(AuthService.verifyFirebaseToken(mockToken)).rejects.toThrow(
        'Invalid Firebase token: missing email or phone number'
      );
    });
  });

  describe('authenticateWithFirebase', () => {
    it('should create new user when user does not exist', async () => {
      // Arrange
      const mockToken = 'firebase_token';
      const decodedToken = {
        uid: 'firebase_uid',
        email: 'newuser@example.com',
        email_verified: true,
        name: 'New User',
        sub: 'firebase_uid',
        aud: 'project_id',
        iss: 'https://securetoken.google.com/project_id',
        exp: Math.floor(Date.now() / 1000) + 3600,
        iat: Math.floor(Date.now() / 1000),
        auth_time: Math.floor(Date.now() / 1000),
        firebase: {
          identities: { email: ['newuser@example.com'] },
          sign_in_provider: 'password',
        },
      };

      const newUser = {
        id: 1,
        email: 'newuser@example.com',
        name: 'New User',
        role: 'renter' as const,
        is_verified: false,
        rating: 0,
        created_at: new Date(),
        updated_at: new Date(),
      };

      (jwt.decode as jest.Mock).mockReturnValue(decodedToken);
      (UserModel.findByEmail as jest.Mock).mockResolvedValue(null);
      (UserModel.create as jest.Mock).mockResolvedValue(newUser);
      (jwt.sign as jest.Mock).mockReturnValue('jwt_token');

      // Act
      const result = await AuthService.authenticateWithFirebase(mockToken);

      // Assert
      expect(result.user).toEqual(newUser);
      expect(result.token).toBe('jwt_token');
      expect(UserModel.create).toHaveBeenCalledWith({
        name: 'New User',
        email: 'newuser@example.com',
        phone: undefined,
        role: 'renter',
      });
    });

    it('should return existing user when user already exists', async () => {
      // Arrange
      const mockToken = 'firebase_token';
      const decodedToken = {
        uid: 'firebase_uid',
        email: 'existing@example.com',
        email_verified: true,
        name: 'Existing User',
        sub: 'firebase_uid',
        aud: 'project_id',
        iss: 'https://securetoken.google.com/project_id',
        exp: Math.floor(Date.now() / 1000) + 3600,
        iat: Math.floor(Date.now() / 1000),
        auth_time: Math.floor(Date.now() / 1000),
        firebase: {
          identities: { email: ['existing@example.com'] },
          sign_in_provider: 'password',
        },
      };

      const existingUser = {
        id: 1,
        email: 'existing@example.com',
        name: 'Existing User',
        role: 'renter' as const,
        is_verified: false,
        rating: 0,
        created_at: new Date(),
        updated_at: new Date(),
      };

      (jwt.decode as jest.Mock).mockReturnValue(decodedToken);
      (UserModel.findByEmail as jest.Mock).mockResolvedValue(existingUser);
      (jwt.sign as jest.Mock).mockReturnValue('jwt_token');

      // Act
      const result = await AuthService.authenticateWithFirebase(mockToken);

      // Assert
      expect(result.user).toEqual(existingUser);
      expect(result.token).toBe('jwt_token');
      expect(UserModel.create).not.toHaveBeenCalled();
    });

    it('should use provided name parameter when creating user', async () => {
      // Arrange
      const mockToken = 'firebase_token';
      const providedName = 'Provided Name';
      const decodedToken = {
        uid: 'firebase_uid',
        email: 'newuser@example.com',
        email_verified: true,
        sub: 'firebase_uid',
        aud: 'project_id',
        iss: 'https://securetoken.google.com/project_id',
        exp: Math.floor(Date.now() / 1000) + 3600,
        iat: Math.floor(Date.now() / 1000),
        auth_time: Math.floor(Date.now() / 1000),
        firebase: {
          identities: { email: ['newuser@example.com'] },
          sign_in_provider: 'password',
        },
      };

      const newUser = {
        id: 1,
        email: 'newuser@example.com',
        name: providedName,
        role: 'renter' as const,
        is_verified: false,
        rating: 0,
        created_at: new Date(),
        updated_at: new Date(),
      };

      (jwt.decode as jest.Mock).mockReturnValue(decodedToken);
      (UserModel.findByEmail as jest.Mock).mockResolvedValue(null);
      (UserModel.create as jest.Mock).mockResolvedValue(newUser);
      (jwt.sign as jest.Mock).mockReturnValue('jwt_token');

      // Act
      const result = await AuthService.authenticateWithFirebase(mockToken, providedName);

      // Assert
      expect(result.user.name).toBe(providedName);
      expect(UserModel.create).toHaveBeenCalledWith({
        name: providedName,
        email: 'newuser@example.com',
        phone: undefined,
        role: 'renter',
      });
    });

    it('should throw error when email and phone are both missing', async () => {
      // Arrange
      const mockToken = 'firebase_token';
      const decodedToken = {
        uid: 'firebase_uid',
        sub: 'firebase_uid',
      };

      (jwt.decode as jest.Mock).mockReturnValue(decodedToken);

      // Act & Assert
      await expect(AuthService.authenticateWithFirebase(mockToken)).rejects.toThrow(
        'Invalid Firebase token: missing email or phone number'
      );
    });
  });
});

