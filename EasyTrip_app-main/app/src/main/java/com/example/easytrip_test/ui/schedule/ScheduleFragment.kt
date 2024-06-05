package com.example.easytrip_test.ui.schedule

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.easytrip_test.databinding.FragmentScheduleBinding

class ScheduleFragment : Fragment() {

  private var _binding: FragmentScheduleBinding? = null
  private val binding get() = _binding!!

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    _binding = FragmentScheduleBinding.inflate(inflater, container, false)
    val root: View = binding.root

    // Your code here

    return root
  }

  override fun onDestroyView() {
    super.onDestroyView()
    _binding = null
  }
}
