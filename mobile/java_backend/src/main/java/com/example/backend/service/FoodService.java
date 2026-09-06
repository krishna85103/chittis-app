package com.example.backend.service;

import com.example.backend.model.Food;
import com.example.backend.repository.FoodRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FoodService {

    private final FoodRepository repository;

    public FoodService(FoodRepository repository) {
        this.repository = repository;
    }

    public List<Food> getAll() {
        return repository.findAll();
    }

    public Optional<Food> getById(Long id) {
        return repository.findById(id);
    }

    public Food create(Food food) {
        return repository.save(food);
    }

    public Food update(Long id, Food food) {

        Food existing = repository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Food not found: " + id));

        existing.setName(food.getName());
        existing.setDescription(food.getDescription());
        existing.setPrice(food.getPrice());

        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
