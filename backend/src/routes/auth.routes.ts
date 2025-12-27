import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// Firebase authentication (handles Google, Email/Password, Phone)
router.post('/firebase', AuthController.authenticateWithFirebase);

// Legacy endpoints (for backward compatibility)
router.post('/google', AuthController.loginWithGoogle);
router.post('/facebook', AuthController.loginWithFacebook);
router.post('/send-otp', AuthController.sendOTP);
router.post('/verify-otp', AuthController.verifyOTP);

// Protected routes
router.get('/me', authenticateToken, AuthController.getCurrentUser);
router.post('/logout', authenticateToken, AuthController.logout);
router.post('/verify-kyc', authenticateToken, AuthController.submitKYC);
router.get('/kyc-status', authenticateToken, AuthController.getKYCStatus);

export default router;








