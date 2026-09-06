package com.example.backend.repository;

import com.example.backend.model.Nuts;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NutsRepository extends JpaRepository<Nuts, Long> {
}
