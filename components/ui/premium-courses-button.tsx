'use client';
import React, { useState } from 'react';
import { Crown } from 'lucide-react';
import { Liquid } from './button-1';

const COLORS = {
  color1: '#FFFFFF',
  color2: '#1E10C5',
  color3: '#9089E2',
  color4: '#FCFCFE',
  color5: '#F9F9FD',
  color6: '#B2B8E7',
  color7: '#0E2DCB',
  color8: '#0017E9',
  color9: '#4743EF',
  color10: '#7D7BF4',
  color11: '#0B06FC',
  color12: '#C5C1EA',
  color13: '#1403DE',
  color14: '#B6BAF6',
  color15: '#C1BEEB',
  color16: '#290ECB',
  color17: '#3F4CC0',
};

interface PremiumCoursesButtonProps {
  onClick?: () => void;
  className?: string;
  label?: string;
}

export const PremiumCoursesButton: React.FC<PremiumCoursesButtonProps> = ({
  onClick,
  className = '',
  label = 'PREMIUM COURSES',
}) => {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <div className={`relative inline-block ${className}`}>
      {/* Outer ambient glow */}
      <div className="absolute w-[112.81%] h-[128.57%] top-[8.57%] left-1/2 -translate-x-1/2 filter blur-[19px] opacity-75 pointer-events-none">
        <span className="absolute inset-0 rounded-full bg-[#8b5cf6] filter blur-[8px] opacity-60"></span>
        <div className="relative w-full h-full overflow-hidden rounded-full">
          <Liquid isHovered={isHovered} colors={COLORS} />
        </div>
      </div>

      {/* Dark inner shadow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-[40%] w-[94%] h-[112%] rounded-full bg-[#010128] filter blur-[7.3px] pointer-events-none"></div>

      {/* Surface Pill */}
      <div className="relative w-full h-full overflow-hidden rounded-full border border-white/30 shadow-[0_4px_25px_rgba(139,92,246,0.5)]">
        <span className="absolute inset-0 rounded-full bg-[#d9d9d9]"></span>
        <span className="absolute inset-0 rounded-full bg-black"></span>
        <Liquid isHovered={isHovered} colors={COLORS} />

        {/* Overlay reflection rings */}
        {[1, 2, 3, 4, 5].map((i) => (
          <span
            key={i}
            className={`absolute inset-0 rounded-full border-solid border-[3px] border-gradient-to-b from-transparent to-white mix-blend-overlay filter ${
              i <= 2 ? 'blur-[3px]' : i === 3 ? 'blur-[5px]' : 'blur-[4px]'
            }`}
          ></span>
        ))}

        {/* Deep blue center glow */}
        <span className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-[40%] w-[70.8%] h-[42.85%] rounded-full filter blur-[15px] bg-[#000066]"></span>

        {/* Clickable button surface */}
        <button
          onClick={onClick}
          onMouseEnter={() => setIsHovered(true)}
          onMouseLeave={() => setIsHovered(false)}
          type="button"
          className="relative z-10 flex items-center justify-center gap-3 px-8 py-3.5 text-white font-bold tracking-wider text-base sm:text-lg uppercase transition-transform duration-200 hover:scale-[1.02] active:scale-[0.98] cursor-pointer"
        >
          <Crown className="w-5 h-5 fill-white flex-shrink-0 drop-shadow" />
          <span className="whitespace-nowrap font-extrabold">{label}</span>
        </button>
      </div>
    </div>
  );
};

export default PremiumCoursesButton;
