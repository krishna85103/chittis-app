package com.testmobile.backend.repository;

import com.testmobile.backend.model.Nuts;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NutsRepository extends JpaRepository<Nuts, Long> {
}
