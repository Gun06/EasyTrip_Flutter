package com.example.easytrip_test.ui.traffic

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.example.easytrip_test.databinding.FragmentTrafficBinding

class TrafficFragment : Fragment() {

  private var _binding: FragmentTrafficBinding? = null

  // This property is only valid between onCreateView and
  // onDestroyView.
  private val binding get() = _binding!!

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    val trafficViewModel =
      ViewModelProvider(this).get(TrafficViewModel::class.java)

    _binding = FragmentTrafficBinding.inflate(inflater, container, false)
    val root: View = binding.root

    val textView: TextView = binding.textTraffic
    trafficViewModel.text.observe(viewLifecycleOwner) {
      textView.text = it
    }
    return root
  }

  override fun onDestroyView() {
    super.onDestroyView()
    _binding = null
  }
}