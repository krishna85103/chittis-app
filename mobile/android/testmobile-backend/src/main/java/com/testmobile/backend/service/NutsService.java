package com.testmobile.backend.service;

import com.testmobile.backend.model.Nuts;
import com.testmobile.backend.repository.NutsRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class NutsService {

    private final NutsRepository repository;

    public NutsService(NutsRepository repository) {
        this.repository = repository;
    }

    public List<Nuts> getAll() {
        return repository.findAll();
    }

    public Optional<Nuts> getById(Long id) {
        return repository.findById(id);
    }

    public Nuts create(Nuts nuts) {
        return repository.save(nuts);
    }

    public Nuts update(Long id, Nuts nuts) {

        Nuts existing = repository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Nuts not found: " + id));

        existing.setName(nuts.getName());
        existing.setDescription(nuts.getDescription());
        existing.setPrice(nuts.getPrice());

        return repository.save(existing);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
