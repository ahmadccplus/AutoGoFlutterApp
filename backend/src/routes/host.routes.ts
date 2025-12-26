import { Router } from 'express';
import { HostController } from '../controllers/host.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// All routes require authentication (but not specific role for demo)
router.use(authenticateToken);

router.get('/cars', HostController.getMyCars);
router.post('/cars', HostController.createCar);
router.put('/cars/:id', HostController.updateCar);
router.delete('/cars/:id', HostController.deleteCar);
router.get('/requests', HostController.getPendingRequests);
router.post('/requests/:id/accept', HostController.acceptRequest);
router.post('/requests/:id/reject', HostController.rejectRequest);

export default router;



