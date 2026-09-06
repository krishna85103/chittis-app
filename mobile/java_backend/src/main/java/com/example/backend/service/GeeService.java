package com.example.backend.service;

import com.example.backend.model.Gee;
import com.example.backend.repository.GeeRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class GeeService {

    private final GeeRepository repository;

    public GeeService(GeeRepository repository) {
        this.repository = repository;
    }

    public List<Gee> getAll() {
        return repository.findAll();
    }

    public Optional<Gee> getById(Long id) {
        return repository.findById(id);
    }

    public Gee create(Gee gee) {
        return repository.save(gee);
    }

    public Gee update(Long id, Gee gee) {

        Gee existing = repository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Gee not found: " + id));

        existing.setName(gee.getName());
        existing.setDescription(gee.getDescription());
        existing.setPrice(gee.getPrice());

        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
