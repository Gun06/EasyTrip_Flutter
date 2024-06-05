package com.example.easytrip_test.ui.mypage

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import androidx.fragment.app.Fragment
import com.example.easytrip_test.R
import com.example.easytrip_test.databinding.FragmentMypageBinding

class MypageFragment : Fragment() {

  private var _binding: FragmentMypageBinding? = null
  private val binding get() = _binding!!

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    _binding = FragmentMypageBinding.inflate(inflater, container, false)
    val root: View = binding.root

    // edit_profile_button 클릭 리스너 설정
    val editProfileButton: ImageButton = binding.root.findViewById(R.id.edit_profile_button)
    editProfileButton.setOnClickListener {
      val intent = Intent(activity, MypageEditActivity::class.java)
      startActivity(intent)
    }

    return root
  }

  override fun onDestroyView() {
    super.onDestroyView()
    _binding = null
  }
}
