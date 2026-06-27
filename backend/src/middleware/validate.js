// src/middleware/validate.js
// Zod-based request body validation middleware factory.
//
// Usage:
//   import { validate } from '../middleware/validate.js';
//   router.post('/route', validate(MyZodSchema), handler);
//
// On success:  attaches req.body (parsed & coerced) and calls next().
// On failure:  responds 400 with { message: '...', errors: [...] }.

/**
 * Factory that returns an Express middleware validating req.body against
 * the given Zod schema.
 *
 * @param {import('zod').ZodTypeAny} schema
 * @returns {import('express').RequestHandler}
 */
export function validate(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      const errors = result.error.errors.map((e) => ({
        path: e.path.join('.'),
        message: e.message,
      }));

      return res.status(400).json({
        message: 'Validation failed',
        errors,
      });
    }

    // Replace req.body with the Zod-coerced / type-safe value.
    req.body = result.data;
    next();
  };
}
