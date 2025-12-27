import { Router } from 'express';
import { CarController } from '../controllers/car.controller';

const router = Router();

router.get('/', CarController.getAllCars);
router.get('/search', CarController.searchCars);
router.get('/:id', CarController.getCarById);

export default router;








