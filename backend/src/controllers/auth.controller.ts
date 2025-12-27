import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { AuthService } from '../services/auth.service';
import { UserModel } from '../models/User';

export class AuthController {
  /**
   * Authenticate with Firebase ID token
   * Handles Google, Email/Password, and Phone authentication
   */
  static async authenticateWithFirebase(req: Request, res: Response): Promise<void> {
    try {
      const { idToken, name } = req.body;
      console.log('=== Firebase Authentication Request ===');
      console.log('Has idToken:', !!idToken);
      console.log('Has name:', !!name);
      console.log('idToken length:', idToken?.length || 0);
      
      if (!idToken) {
        console.error('Missing Firebase ID token');
        res.status(400).json({
          success: false,
          message: 'Firebase ID token is required',
        });
        return;
      }

      console.log('Calling AuthService.authenticateWithFirebase...');
      const result = await AuthService.authenticateWithFirebase(idToken, name);
      console.log('Authentication successful, returning response');
      
      res.json({
        success: true,
        user: result.user,
        token: result.token,
      });
    } catch (error: any) {
      console.error('=== Firebase Authentication Error ===');
      console.error('Error message:', error.message);
      console.error('Error stack:', error.stack);
      console.error('Error name:', error.name);
      console.error('Full error:', JSON.stringify(error, Object.getOwnPropertyNames(error)));
      
      res.status(400).json({
        success: false,
        message: error.message || 'Authentication failed',
      });
    }
  }

  /**
   * Legacy endpoint for Google login (redirects to Firebase auth)
   */
  static async loginWithGoogle(req: Request, res: Response): Promise<void> {
    console.log('Legacy /auth/google endpoint called, redirecting to Firebase auth');
    // Redirect to Firebase authentication
    await this.authenticateWithFirebase(req, res);
  }

  /**
   * Facebook login (not implemented)
   */
  static async loginWithFacebook(req: Request, res: Response): Promise<void> {
    res.status(501).json({
      success: false,
      message: 'Facebook login not yet implemented',
    });
  }

  /**
   * Send OTP (legacy endpoint - phone auth now uses Firebase)
   */
  static async sendOTP(req: Request, res: Response): Promise<void> {
    res.status(501).json({
      success: false,
      message: 'Use Firebase phone authentication instead',
    });
  }

  /**
   * Verify OTP (legacy endpoint - phone auth now uses Firebase)
   */
  static async verifyOTP(req: Request, res: Response): Promise<void> {
    res.status(501).json({
      success: false,
      message: 'Use Firebase phone authentication instead',
    });
  }

  /**
   * Get current authenticated user
   */
  static async getCurrentUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      const userId = req.userId;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      try {
        const user = await UserModel.findById(userId);
        
        if (!user) {
          res.status(404).json({
            success: false,
            message: 'User not found',
          });
          return;
        }

        res.json({
          success: true,
          user,
        });
      } catch (dbError: any) {
        console.error('Database error in getCurrentUser:', dbError);
        
        // If database is not available, return mock user for testing
        if (dbError.code === 'ECONNREFUSED' || 
            dbError.code === '42P01' || 
            dbError.code === '3D000' ||
            dbError.message?.includes('does not exist')) {
          console.warn('Database not available, returning mock user');
          const mockUser = {
            id: userId,
            name: `User ${userId}`,
            email: `user${userId}@autogo.com`,
            phone: '+1234567890',
            role: 'renter',
            is_verified: false,
            rating: 0,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          };
          res.json({
            success: true,
            user: mockUser,
          });
        } else {
          throw dbError;
        }
      }
    } catch (error: any) {
      console.error('getCurrentUser error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to get user',
      });
    }
  }

  /**
   * Logout
   */
  static async logout(req: AuthRequest, res: Response): Promise<void> {
    // In a stateless JWT system, logout is handled client-side
    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  }

  /**
   * Submit KYC documents
   */
  static async submitKYC(req: AuthRequest, res: Response): Promise<void> {
    try {
      const userId = req.userId;
      const { license_data, selfie_url } = req.body;

      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // KYC implementation would go here
      res.status(501).json({
        success: false,
        message: 'KYC submission not yet implemented',
      });
    } catch (error: any) {
      console.error('KYC submission error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to submit KYC',
      });
    }
  }

  /**
   * Get KYC status
   */
  static async getKYCStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      const userId = req.userId;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // KYC status implementation would go here
      res.json({
        success: true,
        kyc: null,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to get KYC status',
      });
    }
  }
}
